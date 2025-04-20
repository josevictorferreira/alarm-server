# frozen_string_literal: true

module AlarmServer
  class MessageHandler
    include Import[:logger, :mqtt_client, :ntfy_client, :message_config]

    def self.call(socket, message)
      new(socket, message).call
    end

    def initialize(socket, message, **args)
      @socket = socket
      @message = message
      @logger = args[:logger]
      @mqtt_client = args[:mqtt_client]
      @ntfy_client = args[:ntfy_client]
      @message_config = args[:message_config]
    end

    def call
      return handle_ping! if @message == 'PING'

      data = parsed_message(@message)

      case data&.type
      when *message_config.filters
        handle_message! data
      else
        handle_error!
      end
    end

    private

    attr_reader :socket

    def parsed_message(message)
      @message_config.parser.new(message, logger).parse
    rescue StandardError => e
      logger.error(e.message)
      nil
    end

    def handle_ping!
      send_response('PONG')
    end

    def handle_message!(data)
      mqtt_client&.publish(data.to_h)
      ntfy_client&.send_notification(data.notification_message) unless data.notification_message.nil?
      logger.info("MESSAGE: #{data}")
    end

    def handle_error!
      logger.error(
        "Unable to handle message, no `#{@message_config.filters}` " \
        'in message type found.'
      )
    end

    def send_response(response)
      socket&.write(response)

      logger.debug("Sent response: #{response}")
    end
  end
end
