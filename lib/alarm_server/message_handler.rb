# frozen_string_literal: true

require 'json'

# This class is responsible for handling messages received by the server.
class MessageHandler
  def self.call(context)
    new(context).call
  end

  def initialize(context)
    @context = context
    @logger = @context.fetch(:logger)
    @address = @context.fetch(:address)
    @data = @context.fetch(:data)
  end

  def call
    return handle_ping! if @data == 'PING'

    case parsed_json_message['type']
    when 'Alarm'
      handle_alarm!
    when 'Log'
      handle_log!
    else
      handle_erro!
    end
  end

  private

  attr_reader :logger, :address, :data

  def handle_ping!
    logger.debug("Received PING from #{address}")
    send_response('PONG')
  end

  def handle_alarm!
    logger.debug("Received ALARM from #{address}")
    logger.info("ALARM: #{parsed_json_message}")
  end

  def handle_log!
    logger.debug("Received LOG from #{address}")
    logger.info("LOG: #{parsed_json_message}")
  end

  def handle_error!
    logger.error("Unknown message type from #{address}: #{parsed_json_message}")
  end

  def parsed_json_message
    JSON.parse(data)
  rescue JSON::ParserError
    logger.error("Failed to parse JSON data from #{address}: #{data}")
    nil
  end

  def send_response(response)
    logger.debug("Sending response to #{address}: #{response}")

    socket = @address.connect
    socket.write(response)
  ensure
    socket&.close
  end
end
