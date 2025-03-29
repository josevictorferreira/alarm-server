# Alarm Server

This is a simple TCP server that listens for alarm messages from ICSee camera devices and forwards them to a MQTT broker.

## Installation

Using nix locally:
```console
$ nix-shell
$ bundle install
$ bundle exec ruby lib/alarm_server.rb
```

Using docker or other container runtime, just check available Makefile commands:
```console
$ make help
```

## Configuration

The server is configured using environment variables. The following variables are available:

- `PORT`: The port the server listens on. Default: `8888`
- `ADDRESS`: The IP addres to be binded on your local machine. Default: `0.0.0.0`
- `MQTT_HOST`: The hostname of the MQTT broker. Default: `localhost`
- `MQTT_PORT`: The port of the MQTT broker. Default: `1883`
- `MQTT_USERNAME`: The username to use when connecting to the MQTT broker. Default: `nil`
- `MQTT_PASSWORD`: The password to use when connecting to the MQTT broker. Default: `nil`

## Usage

The server listens for alarm messages on port `8888`(default). To send an alarm message, connect to the server using a TCP client and send the message as a string. The server will forward the message to the MQTT broker.
