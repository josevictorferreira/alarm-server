# typed: true
# frozen_string_literal: true

require "socket"
require "mqtt"
require_relative "../../config/message_config"
require_relative "../utilities/async_logger"
require_relative "../clients/ntfy_client"

module AlarmServer
  class MessageHandler
    extend T::Sig

    include Import[:logger, :mqtt_client, :ntfy_client, :message_config]

    sig { returns(Utilities::AsyncLogger) }
    attr_reader :logger

    sig { returns(MQTT::Client) }
    attr_reader :mqtt_client

    sig { returns(Clients::NtfyClient) }
    attr_reader :ntfy_client

    sig { returns(MessageConfig) }
    attr_reader :message_config

    class << self
      extend T::Sig

      sig { params(socket: Socket, message: String).void }
      def call(socket, message)
        new(socket, message).call
      end
    end

    sig { params(socket: Socket, message: String, args: T::Hash[Symbol, T.untyped]).void }
    def initialize(socket, message, **args)
      @socket = socket
      @message = message
      @logger = args[:logger]
      @mqtt_client = args[:mqtt_client]
      @ntfy_client = args[:ntfy_client]
      @message_config = args[:message_config]
    end

    def call
      return handle_ping! if @message == "PING"

      data = parsed_message(@message)

      if message_config.filters.include?(data&.type)
        handle_message!(data)
      else
        handle_error!
      end
    end

    private

    attr_reader :socket

    def parsed_message(message)
      @message_config.parser.new(message, message_config.priority, logger).parse
    rescue StandardError => e
      logger.error(e.message)
      nil
    end

    def handle_ping!
      send_response("PONG")
    end

    def handle_message!(data)
      publish_mqtt(data)
      publish_notification(data)
    end

    def publish_mqtt(data)
      return if data.nil? || data.parsed_data.nil?

      mqtt_client&.publish(
        data.to_h,
      )
    end

    sig { params(data: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
    def publish_notification(data)
      notification_data = data.notification_data
      return false if notification_data.message.nil? || notification_data.message == ""

      ntfy_client.send_notification(
        notification_data.title,
        notification_data.message,
        priority: notification_data.priority,
        tags: notification_data.tags,
      )
    end

    sig { void }
    def handle_error!
      logger.error(
        "Unable to handle message, no `#{@message_config.filters}` " \
          "in message type found.",
      )
    end

    sig { params(response: String).void }
    def send_response(response)
      socket&.write(response)

      logger.debug("Sent response: #{response}")
    end
  end
end
