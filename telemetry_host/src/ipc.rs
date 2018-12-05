//! IPC protocol implementation for communication with `pulse_server`
//!
//! Packet format: [length: u32] [JSON encoded payload: Vec<u8>]

use std::io::{self, prelude::*};

use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};

use serde::{
    Serialize,
    de::DeserializeOwned
};

use serde_json;

pub fn read_json<R: Read, T: DeserializeOwned>(reader: &mut R, buf: &mut Vec<u8>) -> io::Result<T> {
    let size = reader.read_u32::<LittleEndian>()? as usize;

    buf.clear();
    buf.resize(size, 0);

    reader.read_exact(buf)?;
    Ok(serde_json::from_slice(buf)?)
}

pub fn write_json<W: Write, T: Serialize>(writer: &mut W, mut buf: &mut Vec<u8>, value: &T)
    -> io::Result<()>
{
    buf.clear();
    serde_json::to_writer(&mut buf, value)?;
    writer.write_u32::<LittleEndian>(buf.len() as u32)?;
    writer.write(buf)?;
    Ok(())
}
