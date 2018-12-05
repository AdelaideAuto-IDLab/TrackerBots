use std::io;

use tokio::codec::{Encoder, Decoder};
use bytes::BytesMut;

/// With a zero byte payload the minimum packet size is 8 bytes long
const MIN_PACKET_LENGTH: usize = 8;

/// A Mavlink codec that acts like a proxy
pub struct MavlinkProxyCodec;

impl Decoder for MavlinkProxyCodec {
    type Item = Vec<u8>;
    type Error = io::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Vec<u8>>, io::Error> {
        if src.len() < MIN_PACKET_LENGTH {
            return Ok(None);
        }

        // Byte 1 in the buffer contains the length of the payload. The total size of the packet is
        // the payload size + the base packet size
        let packet_size = MIN_PACKET_LENGTH + src.as_ref()[1] as usize;

        if src.len() >= packet_size {
            // Remove and return the complete packet from the buffer
            let complete_packet = src.split_to(packet_size);
            return Ok(Some(complete_packet.as_ref().into()));
        }

        // Incomplete packet
        Ok(None)
    }
}

impl Encoder for MavlinkProxyCodec {
    type Item = Vec<u8>;
    type Error = io::Error;

    fn encode(&mut self, msg: Vec<u8>, dst: &mut BytesMut) -> io::Result<()> {
        // Since the purpose of this codec is to simply act as a proxy, the message has alraedy been
        // encoded
        dst.extend_from_slice(&msg);
        Ok(())
    }
}
