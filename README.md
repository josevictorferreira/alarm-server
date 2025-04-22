# Alarm Server

This is a simple TCP server that listens for alarm messages from ICSee camera devices and forwards them to a MQTT broker and Ntfy(if configured).

## Installation

Using nix locally:
```console
$ nix-shell
$ bundle install
$ ./bin/dev
```

Using docker or other container runtime, just check available Makefile commands:
```console
$ make help
```

## Configuration

The server is configured using environment variables. The following variables are available:

- `PORT`: The port the server listens on. Default: `8888`
- `ADDRESS`: The IP addres to be binded on your local machine. Default: `0.0.0.0`
- `LOG_LEVEL`: The log level to use. Default: `info`
- `LOG_OUTPUT`: The output to log to. Default: `STDOUT`.  Can be also a file path.
- `MESSAGE_PARSER`: The message parser to be used. Default: `icsee`. Currently there's only this parser available.
- `MESSAGE_FILTERS`: The filters of the messages to be forwarded, it will match on the "Type" of the message. Default: `alarm,log`
- `MESSAGE_PRIORITY`: The priority of the message to be forwarded, it can be one of the values  `min,low,default,high,max`. Default: `default`
- `MQTT_URL`: The URL of the MQTT broker. Default: `tcp://localhost:1883`
- `MQTT_TOPIC`: The topic to publish the alarm messages to. Default: `alarm`
- `MQTT_CLIENT_ID`: The client ID to use when connecting to the MQTT broker. Default: `alarm_server`
- `NTFY_ENABLED`: In case you want to send messages to ntfy notification service. Default: `false`
- `NTFY_URL`: Ntfy service url. Default: `https://ntfy.sh`
- `NTFY_TOPIC`: Ntfy topic of the message. Default: `camera_alarms`

## Usage

The server listens for alarm messages on port `8888`(default). To send an alarm message, connect to the server using a TCP client and send the message as a string.
Then the server will forward the message to the MQTT broker and Ntfy notfication service(if configured).
