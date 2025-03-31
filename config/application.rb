# frozen_string_literal: true

require 'dry-container'
require 'mqtt'
require 'oj'
require_relative 'mqtt_config'
require_relative 'logger_config'
require_relative 'server_config'
require_relative '../lib/utilities/async_logger'
require_relative '../lib/utilities/tcp_server'

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

  register(:serializer, memoize: true) { Oj }

  register(:server_address, memoize: true) do
    Addrinfo.tcp(ServerConfig.config.address, ServerConfig.config.port)
  end

  register(:tcp_server, memoize: true) do
    Utilities::TcpServer
  end
end
