extern crate env_logger;
extern crate bytes;
#[macro_use] extern crate log;
#[macro_use] extern crate futures;
extern crate tokio;
extern crate tokio_serial;

mod mavlink_codec;
mod transfer;

use std::error::Error;
use std::env;
use std::io;
use std::net::{IpAddr, Ipv4Addr, SocketAddr, ToSocketAddrs};
use std::path::Path;

use tokio::prelude::*;
use tokio::net::{UdpSocket, UdpFramed, TcpStream};
use tokio::reactor::Handle;
use tokio::codec::Decoder;

use mavlink_codec::MavlinkProxyCodec;
use transfer::{EndpointObject, Transfer};

fn main() {
    env_logger::init();

    if let Err(e) = run() {
        println!("{}", e);
    }
}

fn run() -> Result<(), Box<Error>> {
    // Parse the base endpoint
    let base_endpoint_string = env::args().nth(1).ok_or("Must provide source port")?;
    let base_endpoint = parse_endpoint(&base_endpoint_string, true)?;

    // Parse the other endpoints
    let mut other_endpoints = vec![];
    for endpoint in env::args().skip(2) {
        other_endpoints.push(parse_endpoint(&endpoint, false)?);
    }

    if other_endpoints.is_empty() {
        return Err("Must specific at least 1 additional endpoint".into());
    }

    let transfer = Transfer::new(base_endpoint, other_endpoints)
        .map_err(|e| println!("error = {:?}", e));
    tokio::run(transfer);
    Ok(())
}

fn parse_endpoint(value: &str, is_base: bool) -> Result<(String, EndpointObject), Box<Error>> {
    if let Some(index) = value.find("serial:") {
		let path = &value[(index + "serial:".len())..];
        return Ok((path.into(), serial_endpoint(path)?));
    }

    if let Some(index) = value.find("tcp:") {
        let address = &value[(index + "tcp:".len())..];
        return Ok((value.into(), tcp_endpoint(address)?));
    }

    let target_port: u16 = value.parse()?;
    if is_base {
        Ok((value.into(), udp_endpoint(0, target_port)?))
    }
    else {
        Ok((value.into(), udp_endpoint(target_port, 0)?))
    }
}

fn udp_endpoint(target_port: u16, listener_port: u16) -> io::Result<EndpointObject> {
    let target_addr = SocketAddr::new(local_ip(), target_port);
    let listener_addr = SocketAddr::new(local_ip(), listener_port);

    let socket = UdpSocket::bind(&listener_addr)?;

    let endpoint = UdpFramed::new(socket, MavlinkProxyCodec)
        .with(move |item| futures::future::ok((item, target_addr.clone())))
        .map(|(item, _)| item);
    Ok(Box::new(endpoint) as EndpointObject)
}

fn tcp_endpoint<A: ToSocketAddrs>(addr: A) -> io::Result<EndpointObject> {
    let stream = TcpStream::from_std(std::net::TcpStream::connect(addr)?, &Handle::default())?;
    Ok(Box::new(MavlinkProxyCodec.framed(stream)) as EndpointObject)
}

fn serial_endpoint<P>(path: P) -> io::Result<EndpointObject>
where P: AsRef<Path>
{
    use tokio_serial::{Serial, SerialPortSettings};
    use std::time::Duration;

    let settings = SerialPortSettings {
        baud_rate: 57600,
        data_bits: tokio_serial::DataBits::Eight,
        parity: tokio_serial::Parity::None,
        stop_bits: tokio_serial::StopBits::One,
        flow_control: tokio_serial::FlowControl::None,
        timeout: Duration::from_secs(1)
    };

    Ok(Box::new(MavlinkProxyCodec.framed(Serial::from_path(path, &settings)?)) as EndpointObject)
}

fn local_ip() -> IpAddr {
    IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1))
}
