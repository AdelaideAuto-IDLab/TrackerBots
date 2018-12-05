# Telemetry host

_Telemetry host_ provides an REST abstraction layer on top of the raw Mavlink telemetry stream, and pulse stream from pulse server.

## Building

Currently _Telemetry host_ requires a nightly version (2018-12-03) of Rust to compile. If you are using [rustup](https://rustup.rs/) (recommended) to manage your Rust installation, run the following command to configure the build environment:

```
rustup override set nightly-2018-12-03
```

Then build using:

```
cargo build [--release]
```
