# frozen_string_literal: true

require 'io/endpoint'
require 'async'
require 'debug'
require_relative 'alarm_server/message_handler'

BIND_ADDRESS = '0.0.0.0'
BIND_PORT = 8888

address_info = Addrinfo.tcp(BIND_ADDRESS, BIND_PORT)

endpoint = IO::Endpoint::AddressEndpoint.new(address_info)

Async do |task|
  puts "Server listening on #{endpoint}..."

  endpoint.accept do |socket, address|
    task.async do
      while data = socket.readpartial(1024)
        break if data.empty?

        puts "Received data from #{address}: #{data}"
        MessageHandler.process(data)
      end
    rescue EOFError
      puts "Connection closed by #{address}"
    rescue StandardError => e
      puts "Connection with #{address} error: #{e.message}"
    ensure
      socket.close
    end
  end
end
