use std::io::{self, ErrorKind};

use futures::{Async, Future, Poll, Stream, Sink, StartSend};

/// A vector of bytes representing the complete packet of data to be sent between endpoints
pub type TransferItem = Vec<u8>;

/// An endpoint object that can be used as a client in the transfer object
pub type EndpointObject = Box<Endpoint<Item=TransferItem, Error=io::Error,
    SinkItem=TransferItem, SinkError=io::Error> + Send + 'static>;

/// A wrapper trait for an an object that implements both the `Stream` and `Sink` traits
pub trait Endpoint: Stream + Sink {}
impl<T> Endpoint for T where T: Stream + Sink {}

/// A simple macro that returns Ok(Async::NotReady) if the result of an operation is not ready.
///
/// This is similar to the `try_ready!(..)` macro however works with more types.
macro_rules! is_ready {
    ($value:expr) => (match $value {
        Ok(ref inner) if !inner.is_ready() => { return Ok(Async::NotReady); },
        Ok(_) => {},
        Err(ref e) if e.kind() == ErrorKind::WouldBlock => { return Ok(Async::NotReady); },
        Err(e) => return Err(e),
    })
}

/// A wrapper around an endpoint that keeps track of how many items have been sent succesfully to
/// this endpoint.
///
/// Effectively this is used to maintain state between iterations, if Rust ever obtains async/await
/// syntax it is likely that this struct would no longer be needed.
struct EndpointWrapper {
    /// The name of the endpoint
    name: String,

    /// The actual endpoint object
    endpoint: EndpointObject,

    /// The most recently obtained item for this endpoint
    current_item: Option<TransferItem>,

    /// The number of items received from this endpoint
    items_recv: usize,

    /// The number of items sent to this endpoint
    items_sent: usize,
}

impl EndpointWrapper {
    fn new(name: String, endpoint: EndpointObject) -> EndpointWrapper {
        EndpointWrapper {
            name: name,
            endpoint: endpoint,
            current_item: None,
            items_recv: 0,
            items_sent: 0,
        }
    }
}

impl Stream for EndpointWrapper {
    type Item = TransferItem;
    type Error = io::Error;

    fn poll(&mut self) -> Poll<Option<TransferItem>, io::Error> {
        self.endpoint.poll()
    }
}

impl Sink for EndpointWrapper {
    type SinkItem = TransferItem;
    type SinkError = io::Error;

    fn start_send(&mut self, item: TransferItem) -> StartSend<TransferItem, io::Error> {
        let result = self.endpoint.start_send(item);
        if result.as_ref().map(|x| x.is_ready()).unwrap_or(false) {
            self.items_sent += 1;
        }
        result
    }

    fn poll_complete(&mut self) -> Poll<(), Self::SinkError> {
        self.endpoint.poll_complete()
    }
}

impl EndpointWrapper {
    /// Retrieve the next item from this endpoint
    fn next_item(&mut self) -> Poll<(), io::Error> {
        self.current_item = try_ready!(self.poll());
        self.items_recv += 1;

        Ok(().into())
    }
}

/// A future for managing the transfer of data to and from one endpoint to multiple other endpoints.
pub struct Transfer {
    /// The base endpoint of this transfrom
    base_endpoint: EndpointWrapper,

    /// The other connected endpoints
    other_endpoints: Vec<EndpointWrapper>,
}

impl Transfer {
    /// Create a new transfer object
    pub fn new(base: (String, EndpointObject), others: Vec<(String, EndpointObject)>) -> Transfer {
        Transfer {
            base_endpoint: EndpointWrapper::new(base.0, base.1),
            other_endpoints: others
                .into_iter()
                .map(|(name, obj)| EndpointWrapper::new(name, obj))
                .collect()
        }
    }

    /// Keeps track of sending data from the base endpoint to all other endpoints
    fn base_to_others(&mut self) -> Poll<(), io::Error> {
        // Transfer the current item to any endpoints that are yet to receive it
        if let Some(ref item) = self.base_endpoint.current_item {
            let i = self.base_endpoint.items_recv;
            for endpoint in self.other_endpoints.iter_mut().filter(|x| x.items_sent < i) {
                is_ready!(endpoint.start_send(item.clone()));
                debug!("Packet sent from: {} (primary) to {}.", self.base_endpoint.name, endpoint.name);
            }
        }

        // Make progress writing data to each of the endpoints
        for endpoint in &mut self.other_endpoints {
            is_ready!(endpoint.poll_complete());
        }

        // Read the next item from the base endpoint
        self.base_endpoint.next_item()
    }

    /// Keeps track of sending data from other endpoints to the base endpoint
    fn others_to_base(&mut self) -> Poll<(), io::Error> {
        // Make progress writing data to the base endpoint
        is_ready!(self.base_endpoint.poll_complete());

        // Try to send any pending items from the other endpoints to the base endpoint
        for endpoint in &mut self.other_endpoints {
            if let Some(ref item) = endpoint.current_item {
                is_ready!(self.base_endpoint.start_send(item.clone()));
                debug!("Packet sent from: {} to {} (primary).", endpoint.name, self.base_endpoint.name);
            }
            endpoint.current_item = None;
        }

        // Try to get a new item from any of the connected endpoints
        let mut is_ready = false;
        for endpoint in &mut self.other_endpoints {
            is_ready = match endpoint.next_item() {
                Ok(ref inner) => inner.is_ready(),
                Err(ref e) if e.kind() == ErrorKind::WouldBlock => false,
                Err(e) => return Err(e),
            };
        }

        // If any of the endpoints are ready to be read from, then this future is set to the ready
        // state.
        if is_ready { Ok(().into()) } else { Ok(Async::NotReady) }
    }
}

impl Future for Transfer {
    type Item = ();
    type Error = io::Error;

    fn poll(&mut self) -> Poll<(), io::Error> {
        loop {
            match (self.base_to_others()?, self.others_to_base()?) {
                (Async::NotReady, Async::NotReady) => return Ok(Async::NotReady),
                _ => {}
            }
        }
    }
}
