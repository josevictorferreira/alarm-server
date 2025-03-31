# frozen_string_literal: true

require 'debug'

module AlarmServer
  class MessageHandler
    include Import[:logger, :mqtt_client, :serializer]

    def self.call(socket, message)
      new(socket, message).call
    end

    def initialize(socket, message, **args)
      @socket = socket
      @message = message
      @logger = args[:logger]
      @mqtt_client = args[:mqtt_client]
      @serializer = args[:serializer]
    end

    def call
      return handle_ping! if @message == 'PING'

      @data = parsed_json_message(@message)

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

    attr_reader :socket, :data

    def handle_ping!
      send_response('PONG')
    end

    def handle_alarm!
      mqtt_client.publish(data)
      logger.info("ALARM: #{data}")
    end

    def handle_log!
      mqtt_client.publish(data)
      logger.info("LOG: #{data}")
    end

    def handle_error!
      logger.error('Unable to handle message, no `Type` attribute found.')
    end

    def parsed_json_message(data_str)
      serializer.load(data_str, mode: :compat, symbol_keys: true, cache_keys: true)
    rescue StandardError => _e
      logger.error("Unable to parse JSON, payload: `#{data_str}`")
      nil
    end

    def send_response(response)
      socket&.write(response)

      logger.debug("Sent response: #{response}")
    end
  end
end
