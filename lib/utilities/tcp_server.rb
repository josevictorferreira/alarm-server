# frozen_string_literal: true

require 'io/endpoint'

module Utilities
  class TcpServer
    attr_reader :address, :handler, :logger

    def initialize(address:, handler:, logger:)
      @address = address
      @handler = handler
      @logger = logger
    end

    def start
      Async do |task|
        endpoint = IO::Endpoint::AddressEndpoint.new(address)
        logger.info("Listening #{endpoint}")

        endpoint.accept do |socket, address|
          logger.debug("Connection established with #{address.ip_address}")
          async_handle_socket(task, socket, address.ip_address)
        end
      end
    end

    def self.start(**args)
      new(**args).start
    end

    private

    def async_handle_socket(task, socket, address)
      task.async do
        message = read_message(socket)

        handler.call(socket, message)
      rescue StandardError => e
        logger.error("Connection with #{address} exited \nError: #{e.message}\n Backtrace: #{e.backtrace}")
      ensure
        logger.debug("Connection closed with #{address}")
        socket&.close
      end
    end

    def read_message(socket)
      full_message = ''
      while (raw_data = socket.readpartial(1024))
        full_message += raw_data
        break if full_message.end_with?("\n")
      end
      parse_message(full_message)
    rescue EOFError
      logger.debug('Connection closed by client') && '{}'
    end

    def parse_message(full_message)
      json_start_idx = full_message.index('{')
      full_data = if json_start_idx.nil?
                    full_message
                  else
                    full_message[json_start_idx..]
                  end
      full_data.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').chomp
    end
  end
end
