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
- `MQTT_URL`: The URL of the MQTT broker. Default: `tcp://localhost:1883`
- `MQTT_TOPIC`: The topic to publish the alarm messages to. Default: `alarm`
- `MQTT_CLIENT_ID`: The client ID to use when connecting to the MQTT broker. Default: `alarm_server`
- `LOG_LEVEL`: The log level to use. Default: `info`
- `LOG_OUTPUT`: The output to log to. Default: `STDOUT`.  Can be also a file path.

## Usage

The server listens for alarm messages on port `8888`(default). To send an alarm message, connect to the server using a TCP client and send the message as a string. The server will forward the message to the MQTT broker.
