# typed: false
# frozen_string_literal: true

require "dry-container"
require "mqtt"
require "oj"
require_relative "logger_config"
require_relative "server_config"
require_relative "mqtt_config"
require_relative "ntfy_config"
require_relative "message_config"
require_relative "../lib/utilities/async_logger"
require_relative "../lib/utilities/tcp_server"
require_relative "../lib/clients/ntfy_client"

class Application
  extend Dry::Container::Mixin

  register(:mqtt_client) do
    client = MQTT::Client.connect(MqttConfig.config.url)
    at_exit { client.disconnect }
    client
  end

  register(:logger, memoize: true) do
    logger_client = Utilities::AsyncLogger.new(LoggerConfig.config.output, LoggerConfig.config.level)
    at_exit { logger_client.close }
    logger_client
  end

  register(:server_address, memoize: true) do
    Addrinfo.tcp(ServerConfig.config.address, ServerConfig.config.port)
  end

  register(:tcp_server, memoize: true) do
    Utilities::TcpServer
  end

  register(:ntfy_client, memoize: true) do
    if NtfyConfig.config.enabled
      Clients::NtfyClient.new(
        url: NtfyConfig.config.url,
        topic: NtfyConfig.config.topic,
      )
    end
  end

  register(:message_config, memoize: true) do
    MessageConfig.config
  end
end
