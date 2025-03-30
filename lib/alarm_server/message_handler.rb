# frozen_string_literal: true

require 'oj'
require 'debug'

# This class is responsible for handling messages received by the server.
class MessageHandler
  def self.call(context)
    new(context).call
  end

  def initialize(context)
    @context = context
    @logger = @context.fetch(:logger)
    @socket = @context.fetch(:socket)
    @raw_data = @context.fetch(:raw_data)
  end

  def call
    return handle_ping! if @raw_data == 'PING'

    @data = parsed_json_message(@raw_data)

    case data&.dig(:Type)
    when 'Alarm'
      handle_alarm!
    when 'Log'
      handle_log!
    else
      handle_error!
    end
  end

  private

  attr_reader :logger, :socket, :data

  def handle_ping!
    send_response('PONG')
  end

  def handle_alarm!
    logger.info("ALARM: #{data}")
  end

  def handle_log!
    logger.info("LOG: #{data}")
  end

  def handle_error!
    logger.error('Unable to handle message, no `Type` attribute found.')
  end

  def parsed_json_message(raw_data)
    json_start_idx = raw_data.index('{')
    return nil if json_start_idx.nil?

    data_str = raw_data[json_start_idx..]

    Oj.load(data_str, mode: :compat, symbol_keys: true, cache_keys: true)
  rescue StandardError => _e
    logger.error("Unable to parse JSON, payload: `#{data_str}`")
    nil
  end

  def send_response(response)
    socket&.write(response)

    logger.debug("Sent response: #{response}")
  end
end
