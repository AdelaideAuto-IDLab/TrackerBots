## Instructions to install the pulse_server on an Intel Edison board

## 1. Installing the rust version

* Download the rust tar file from: `https://www.rust-lang.org/en-US/other-installers.html` (Standalone installers)
* Extract the `tar.gz` locally
* Delete unneeded rust components
* Run `rustup toolchain link custom /home/root/rust-nightly-i686-unknown-linux-gnu/rustc`

## 2. Installing `pulse_server`

* Configure networking:
    * Connect phone to `football` network.
    * Connect phone to computer via USB 
    * Set phone into USB tethering mode
    * Manually configure the routing table (in the case of overlapping routing) e.g. for Edison IP address = `192.168.2.15` and gateway address = `192.168.42.129`
	```
	route add 192.168.2.15 MASK 255.255.255.255 192.168.42.129
	```
    * Forward a http proxy from the host machine to the edison `ssh -R 3128:localhost:3128 root@192.168.2.15` (for a squid proxy running on port 3128)
    * Ensure that the http proxy is set: `git config --global http.proxy http://localhost:3128` and in `~/.cargo/config`
* Check that the Edison time is up to date (can cause certificate errors)
* Clone the TrackerBots repo: `git clone git@github.com:AdelaideAuto-IDLab/TrackerBots.git`
* Navigate to `~/TrackerBots/code/telemetry/pulse_server`
* Run the command:
```
RUSTFLAGS="--sysroot /home/root/rust-nightly-i686-unknown-linux-gnu/rust-std-i686-unknown-linux-gnu/" ~/cargo run --release
```

## 3. Set Auto start config

* Run the `copy.sh` and `enable.sh` scripts in `services` folder

* Check if `pulse_server` is running or not:

  ```
  journalctl -r -u pulse_server # check if pulse server is working
  ```

* If not, you can restart it by:

  ```
  systemctl restart pulse_server # restart pulse server
  ```

## 4. Enable Access Point (AP) mode for the board

https://software.intel.com/en-us/getting-started-with-ap-mode-for-intel-edison-board
The following instructions work best on an Intel® Edison board assembled with the Arduino expansion board. 
To enter AP Mode with the Intel® Edison mini breakout board, 
you must establish a serial communication session with your board and use the command line:

```
configure_edison --enableOneTimeSetup.
```

Entering AP mode and connecting to a Wi-Fi network

```
* On your board, hold down the button labeled PWR for more than 2 seconds but no longer than 7 seconds. Around 4 seconds is sufficient.

* The LED at JS2 near the center of the board should now be blinking. It will remain blinking as long as your board is in AP mode.
* In a few moments, a Wi-Fi network hotspot appears. Typically, its name is in the form of: Edison-xx-xx, where xx-xx is the last two places of your board's Wi-Fi mac address. This mac address is on a label within the plastic chip holder that contained the Intel® Edison chipset within the packaging. However, if you have given your board a name, the Wi-Fi hotspot has the same name.
* When you find your board's Wi-Fi hotspot, attempt to connect.  The passcode necessary to connect is the chipset serial number, which is also on the label in the plastic chip holder beneath the mac address.  Additionally, a small white label on the Intel® Edison chipset itself also states the serial number. The passcode is case-sensitive.
* Once you have connected to the hotspot, open a browser (preferably Firefox or Chrome) and enter Edison.local in the URL bar. The following screen displays: 
```

You want manuelly to switch back from AP mode in Client mode of Wifi? simply run 
configure_edison --setup again

```
systemctl stop hostapd
systemctl disable hostapd
systemctl enable wpa_supplicant
systemctl start wpa_supplicant
wpa_cli reconfigure
wpa_cli select_network wlan0
udhcpc -i wlan0
```

Install nmap to check port open or not

```
sudo apt-get install nmap
nmap -p 22 192.168.42.1
```

Then you need to connect your laptop to Edison AP.