# IO Proxy

_IO Proxy_ is a tool for multiplexing Mavlink messages between different I/O connections. An instance consists of a single primary connection and on or more secondary connections connections. Each message received by the primary connection is cloned and forwarded econdary connections. Any message sent to a secondary connection is forwarded to the primary connection. Muxing between secondary connections is performed at the Mavlink message level.

IO Proxy was built as a high performance (limited) replacement for [MAVProxy](https://ardupilot.github.io/MAVProxy/html/index.html). For general purpose use (e.g. development) it might be easier to use MAVProxy, however it is recommended to use _IO Proxy_ when running on the Edison.

## Building

_IO Proxy_ is a Rust program. Building it requires `cargo` and `rustc`, see [Install Rust](https://www.rust-lang.org/en-US/install.html) for installation instructions.

After installing Rust, compile by running:

```
cargo build [--release]
```

## Example usage

Proxy a primary UDP port (14550) to multiple other secondary UDP ports (14551, 14552):

```
cargo run --release -- 14550 14551 14552
```

Expose UDP endpoints for a primary Serial link:

```
cargo run --release -- serial:/dev/ttyUSB0 14551 14552
```
