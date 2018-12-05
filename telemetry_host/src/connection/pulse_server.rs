use std::{io, thread, net::TcpStream, time::Duration, sync::mpsc::{Sender, Receiver, channel}};
use crossbeam_utils;

use common::{DownMessage};
use types::{ServerMessage, PulseServerMessage, PulseWithTelemetry};

use ipc;
use connection::drone;

pub fn connect(addr: String, mut tx: Sender<ServerMessage>) -> Sender<PulseServerMessage> {
    let (sender, mut receiver) = channel();

    thread::spawn(move || {
        loop {
            if let Err(e) = pulse_client_loop(&addr, &mut tx, &mut receiver) {
                println!("{}", e);
            }
            thread::sleep(Duration::from_secs(5));
        }
    });

    sender
}

fn pulse_client_loop(addr: &str,
    to: &mut Sender<ServerMessage>,
    from: &mut Receiver<PulseServerMessage>
) -> io::Result<()>
{
    println!("Connecting to pulse stream: {}", addr);

    let connection = TcpStream::connect(&addr[..])?;
    let writer = connection.try_clone()?;

    crossbeam_utils::thread::scope(|scope| {
        scope.spawn(|_| tx_loop(writer, from));
        rx_loop(connection, to)
    }).unwrap()
}

fn rx_loop(mut conn: TcpStream, to: &mut Sender<ServerMessage>) -> io::Result<()> {
    let mut buffer = vec![];
    loop {
        let DownMessage::Pulse(mut pulse) = ipc::read_json(&mut conn, &mut buffer)?;

        // Convert pulse to dB
        pulse.signal_strength = 20.0 * pulse.signal_strength.log10();
        println!("Pulse from client: {:?}", pulse);

        let data = PulseWithTelemetry { telemetry: drone::get_telemetry(), pulse };
        to.send(ServerMessage::Pulse(data)).unwrap();
    }
}

fn tx_loop(mut conn: TcpStream, from: &mut Receiver<PulseServerMessage>) -> io::Result<()> {
    let mut buffer = vec![];

    ipc::write_json(&mut conn, &mut buffer, &PulseServerMessage::Start)?;
    while let Ok(msg) = from.recv() {
        ipc::write_json(&mut conn, &mut buffer, &msg)?;
    }

    Ok(())
}
