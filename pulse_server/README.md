# Pulse Server

A tool for detecting animal tag pulses from a connected SDR. Currently the following SDRs are supported and have been tested to work:

* HackRF One
* Airspy Mini

_Pulse Server_ hosts a TCP server that is used for sending detected pulses and receiving configuration updates. Messages are sent via a simple JSON based protocol. Each message is prefixed with the message length (an unsigned 32-bit integer LE encoded), followed by a JSON string UTF-8 encoded.

### _Pulse Server_ accepts message of the following formats:

#### Configure the detector:

```json
{
    "PulseTargets": [
        {
            "freq": 150130000.0,
            "duration": 0.0185,
            "duration_variance": 0.002,
            "threshold": 0.0005,
            "edge_length": 10,
            "gain": 0,
            "peak_lookahead": 5
        }
    ]
}
```

#### Configure the SDR:

```json
{
  "SdrConfig": {
        "samp_rate": 6000000,
        "center_freq": 151000000,
        "auto_gain": false,
        "lna_gain": 8,
        "vga_gain": 8,
        "amp_enable": false,
        "antenna_enable": false,
        "baseband_filter": null
    }
}
```

#### Start or stop the detector:

```json
"Start"
```
```json
"Stop"
```

### _Pulse Server_ sends messages of the following format:


```json
{
    "Pulse": {
        "target_id": 0,
        "freq": 150130000.0,
        "duration": 0.0185,
        "signal_strength": 0.1,
        "gain": 0.0,
        "timestamp": { "seconds": 0, "nanos": 0 },
    }
}
```

## Building

_Pulse Server_ is a Rust program. Building it requires `cargo` and `rustc`, see [Install Rust](https://www.rust-lang.org/en-US/install.html) for installation instructions.

In addition to Rust, a C compiler and the following libraries: `libusb-1.0`, `libpthread` are required to build the SDR host libraries. These are generally available via your package manager (on Linux) or as prebuild binaries on Windows.

Compilation has been tested on: Ubuntu (x86_64), Windows 10 x86_64 and Yocto Linux

Once the dependencies are installed, compile by running:

```
cargo build [--release]
```

(Note: it can be difficult to configure a Yocto sysroot to easily cross-compile the tool for the Edison, so a binary is provided on the release page).

## Configuration

Initial configuration is loaded from the `./config/task.json` file. The `addr` field controls the binding address of the TCP Server, and `mode` fields controls the running mode. `mode` should be set to one of the following: One of: `"HackRF"`, `"Airspy"`, or `"Test": { "rate_ms": 1000, "freq": 150e6 }` depending on the connected SDR.

For each mode there is a corresponding configuration file that is loaded, see the files in the `./config` directory for more information.
