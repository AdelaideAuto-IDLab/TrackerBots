use std::{
    error::Error,
    io::{self, Read, Write},
    net::{TcpListener, TcpStream, ToSocketAddrs},
    thread,
    sync::mpsc::{channel, Sender, Receiver},
};

use byteorder::{LittleEndian, ReadBytesExt, WriteBytesExt};
use serde_json;

use types::{InnerMessage, DownMessage};

pub struct Server {
    to_client: (Sender<InnerMessage>, Receiver<InnerMessage>),
    from_client_tx: Sender<InnerMessage>,
}

impl Server {
    pub fn new() -> (Server, Receiver<InnerMessage>) {
        let (from_client_tx, from_client_rx) = channel();
        (Server { to_client: channel(), from_client_tx }, from_client_rx)
    }

    pub fn client_sender(&self) -> Sender<InnerMessage> {
        self.to_client.0.clone()
    }

    pub fn listen<A: ToSocketAddrs>(self, addr: A) -> io::Result<()> {
        let listener = TcpListener::bind(addr)?;

        let (to_client_tx, to_client_rx) = self.to_client;
        let from_client_tx = self.from_client_tx;

        thread::spawn(move || match server_listener(to_client_rx, from_client_tx) {
            Ok(..) => println!("[Server] Server listener exited"),
            Err(e) => println!("[Server] Server listener exited: {:?}", e),
        });

        for stream in listener.incoming() {
            match stream {
                Ok(conn) => to_client_tx.send(InnerMessage::NewConnection(conn)).unwrap(),
                Err(e) => println!("Connection failed with client: {:?}", e),
            }
        }

        Ok(())
    }
}

struct ClientHandle {
    connected: bool,
    channel: Sender<DownMessage>,
}

impl ClientHandle {
    fn new(channel: Sender<DownMessage>) -> ClientHandle {
        ClientHandle { connected: true, channel }
    }

    fn send(&mut self, msg: DownMessage) {
        if let Err(e) = self.channel.send(msg) {
            println!("Error sending message to client: {:?}", e);
            self.connected = false;
        }
    }
}

fn server_listener(rx: Receiver<InnerMessage>, tx: Sender<InnerMessage>) -> Result<(), Box<Error>> {
    let mut clients = vec![];

    loop {
        let msg = rx.recv()?;

        if let InnerMessage::NewConnection(conn) = msg {
            let (to_client, from_server) = channel();
            clients.push(ClientHandle::new(to_client));
            Client::new(conn, from_server, tx.clone()).handle();
        }
        else {
            let msg = msg.down().unwrap();

            for client in &mut clients {
                client.send(msg.clone());
            }

            // Remove all disconnected clients
            clients.retain(|c| c.connected);
        }
    }
}

struct Client {
    conn: TcpStream,
    rx: Receiver<DownMessage>,
    tx: Sender<InnerMessage>,
}

impl Client {
    fn new(conn: TcpStream, rx: Receiver<DownMessage>, tx: Sender<InnerMessage>) -> Client {
        Client { conn, rx, tx }
    }

    fn handle(self) {
        // Server -> Client thread
        let writer = self.conn.try_clone().unwrap();
        let from_server = self.rx;
        thread::spawn(move || match to_client(writer, from_server) {
            Ok(..) => println!("[Server -> Client] Client exited"),
            Err(e) => println!("[Server -> Client] Client exited: {:?}", e),
        });

        // Client -> Server thread
        let reader = self.conn;
        let to_server = self.tx;
        thread::spawn(move || match from_client(reader, to_server) {
            Ok(..) => println!("[Server -> Client] Client exited"),
            Err(e) => println!("[Client -> Server] Client exited: {:?}", e),
        });
    }
}

fn to_client(mut writer: TcpStream, from_server: Receiver<DownMessage>) -> Result<(), Box<Error>> {
    let mut buf = vec![];

    for val in from_server {
        let out = serde_json::to_vec(&val)?;

        buf.clear();
        buf.write_u32::<LittleEndian>(out.len() as u32)?;
        buf.extend(out);

        writer.write_all(&buf)?;
    }

    Ok(())
}

fn from_client(mut reader: TcpStream, to_server: Sender<InnerMessage>) -> Result<(), Box<Error>> {
    let mut buf = vec![];
    loop {
        let len = reader.read_u32::<LittleEndian>()?;
        if len > 4096 {
            return Err("Client message to large".into());
        }

        buf.resize(len as usize, 0);
        reader.read_exact(&mut buf)?;

        let msg = InnerMessage::from_up(serde_json::from_slice(&buf)?);
        to_server.send(msg)?;
    }
}
