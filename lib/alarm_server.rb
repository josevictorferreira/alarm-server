# frozen_string_literal: true

require 'io/endpoint'
require 'async'
require 'debug'
require_relative 'alarm_server/async_logger'
require_relative 'alarm_server/message_handler'

# AlarmServer module
module AlarmServer
  BIND_ADDRESS = ENV.fetch('ADDRESS', '0.0.0.0').freeze
  BIND_PORT = ENV.fetch('PORT', 8888).to_i.freeze
  LOG_LEVEL = ENV.fetch('LOG_LEVEL', 'debug').to_sym.freeze
  ADDRESS_INFO = Addrinfo.tcp(BIND_ADDRESS, BIND_PORT).freeze

  def self.run!
    Async do |task|
      endpoint = IO::Endpoint::AddressEndpoint.new(ADDRESS_INFO)
      logger.info("Listening #{endpoint} ...")

      endpoint.accept do |socket, address|
        async_handle_socket(task, socket, address) do
          handle_data(socket, address)
        end
      end
    end
  end

  def self.logger
    @logger ||= AsyncLogger.new($stdout, LOG_LEVEL)
  end

  def self.async_handle_socket(task, socket, address)
    task.async do
      yield
    rescue EOFError
      logger.debug("Connection closed by #{address}")
    rescue StandardError => e
      logger.error("Connection with #{address} error: #{e.message}")
    ensure
      socket.close
    end
  end

  def self.handle_data(socket, address)
    while (data = socket.readpartial(1024))
      break if data.empty?

      context = { logger: logger, address: address, data: data }
      MessageHandler.call(context)
    end
  end

  private_class_method :async_handle_socket, :handle_data
end
