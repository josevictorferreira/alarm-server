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
  LOG_LEVEL = ENV.fetch('LOG_LEVEL', 'INFO').downcase.to_sym.freeze
  LOG_OUTPUT = ENV.fetch('LOG_OUTPUT', 'STDOUT').freeze
  ADDRESS_INFO = Addrinfo.tcp(BIND_ADDRESS, BIND_PORT).freeze

  def self.run!
    Async do |task|
      endpoint = IO::Endpoint::AddressEndpoint.new(ADDRESS_INFO)
      logger.info("Listening #{endpoint}")

      endpoint.accept do |socket, address|
        logger.debug("Connection established with #{address.ip_address}")
        async_handle_socket(task, socket, address.ip_address)
      end
    end
  ensure
    logger&.close
  end

  def self.logger
    @logger ||= AsyncLogger.new(LOG_OUTPUT, LOG_LEVEL)
  end

  def self.async_handle_socket(task, socket, address)
    task.async do
      raw_data = read_message(socket)

      MessageHandler.call({ logger: logger, socket: socket, raw_data: raw_data })
    rescue StandardError => e
      logger.error("Connection with #{address} exited \nError: #{e.message}\n Backtrace: #{e.backtrace}")
    ensure
      logger.debug("Connection closed with #{address}")
      socket&.close
    end
  end

  def self.read_message(socket)
    full_data = ''
    while (raw_data = socket.readpartial(1024))
      full_data += raw_data
      break if raw_data.end_with?("\n")
    end
    full_data.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').chomp
  rescue EOFError
    logger.debug('Connection closed by client') && ''
  end

  private_class_method :async_handle_socket, :read_message
end
