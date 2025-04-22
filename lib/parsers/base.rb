# frozen_string_literal: true

require 'oj'
require 'erb'

module Parsers
  # A Data structure to hold parsed message data
  MessageData = Data.define(:message_id, :device_id, :type, :time, :notification_data, :parsed_data, :raw_message) do
    def initialize(message_id:, device_id:, type:, time:, notification_data:, parsed_data:, raw_message:)
      super(
        message_id: String(message_id),
        device_id: String(device_id),
        type: String(type),
        time: Time.at(time),
        notification_data: notification_data,
        parsed_data: Hash(parsed_data),
        raw_message: String(raw_message)
      )
    end
  end

  NotificationData = Data.define(:title, :priority, :tags, :message) do
    def initialize(title:, priority:, tags:, message:)
      super(
        title: String(title),
        priority: priority.to_sym,
        tags: Array(tags),
        message: String(message)
      )
    end
  end

  NotificationContentData = Data.define(:device_name, :device_address, :device_channel, :formatted_time, :status) do
    def initialize(device_name:, device_address:, device_channel:, formatted_time:, status:)
      super(
        device_name: String(device_name),
        device_address: String(device_address),
        device_channel: String(device_channel),
        formatted_time: String(formatted_time),
        status: String(status)
      )
    end
  end

  class ParserError < StandardError; end

  # @abstract
  # This class serves as a base class for all parsers in the application.
  # It defines the common interface and provides basic functionality for parsing messages.
  #
  # @see Parsers::Icsee for an example of a concrete parser implementation.

  # A Base module for all parsers
  # This module can be used to define common functionality or constants for all parsers
  # in your application.
  #
  # @example
  #   module Parsers
  #     class MyParser < Base
  #       def parse(data)
  #         # Parsing logic here
  #       end
  #     end
  #   end
  class Base
    attr_reader :raw_data, :priority, :parsed_data, :logger

    # @param data [String] The data to be parsed.
    # @param logger [Logger] An optional logger instance for logging.
    def initialize(raw_data, priority = :default, logger = nil)
      @raw_data = String(raw_data)
      @parsed_data = Hash(parsed_json_message(raw_data))
      @priority = priority.to_sym
      @logger = logger
    end

    # This method can be overridden in subclasses to provide specific parsing logic.
    # @return [MessageData] The parsed result.
    def parse
      raise NotImplementedError, 'Subclasses must implement the parse method'
    end

    private

    def rendered_template(template, notification_content_data)
      template_content = File.read(File.expand_path("templates/#{template}.erb", __dir__), encoding: 'UTF-8')
      @notification_content_data = notification_content_data
      ERB.new(template_content).result(binding).force_encoding('UTF-8')
    end

    def parsed_json_message(data_str)
      Oj.load(data_str, mode: :compat, symbol_keys: true, cache_keys: true)
    rescue StandardError => _e
      raise ParserError, "Unable to parse JSON, payload: `#{data_str}`"
    end
  end
end
