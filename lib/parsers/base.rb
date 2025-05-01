# typed: true
# frozen_string_literal: true

require "oj"
require "erb"

module Parsers
  extend T::Sig

  MessageData = Data.define(:message_id, :device_id, :type, :time, :notification_data, :parsed_data, :raw_message) do
    extend T::Sig

    sig do
      params(
        message_id: String,
        device_id: String,
        type: String,
        time: Time,
        notification_data: NotificationData,
        parsed_data: Hash,
        raw_message: String,
      ).returns(T.self_type)
    end
    def initialize(message_id:, device_id:, type:, time:, notification_data:, parsed_data:, raw_message:)
      super(
        message_id: message_id,
        device_id: device_id,
        type: type,
        time: time,
        notification_data: notification_data,
        parsed_data: parsed_data,
        raw_message: raw_message
      )
    end
  end

  NotificationData = Data.define(:title, :priority, :tags, :message) do
    extend T::Sig

    sig do
      params(
        title: String,
        priority: Symbol,
        tags: Array,
        message: String,
      ).returns(T.self_type)
    end
    def initialize(title:, priority:, tags:, message:)
      super(
        title: title,
        priority: priority,
        tags: tags,
        message: message
      )
    end
  end

  NotificationContentData = Data.define(:device_name, :device_address, :device_channel, :formatted_time, :status) do
    extend T::Sig

    sig do
      params(
        device_name: String,
        device_address: String,
        device_channel: String,
        formatted_time: String,
        status: String,
      ).returns(T.self_type)
    end
    def initialize(device_name:, device_address:, device_channel:, formatted_time:, status:)
      super(
        device_name: device_name,
        device_address: device_address,
        device_channel: device_channel,
        formatted_time: formatted_time,
        status: status
      )
    end
  end

  class ParserError < StandardError; end

  class Base
    extend T::Sig

    sig { returns(String) }
    attr_reader :raw_data

    sig { returns(Symbol) }
    attr_reader :priority

    sig { returns(T.nilable(Logger)) }
    attr_reader :logger

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :parsed_data

    sig { params(raw_data: String, priority: Symbol, logger: T.nilable(Logger)).void }
    def initialize(raw_data, priority = :default, logger = nil)
      @raw_data = String(raw_data)
      @parsed_data = parsed_json_message(raw_data)
      @priority = priority.to_sym
      @logger = logger
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def parse
      raise NotImplementedError, "Subclasses must implement the parse method"
    end

    private

    sig { params(template: String, notification_content_data: NotificationContentData).returns(String) }
    def rendered_template(template, notification_content_data)
      template_content = File.read(File.expand_path("templates/#{template}.erb", __dir__), encoding: "UTF-8")
      @notification_content_data = notification_content_data
      ERB.new(template_content).result(binding).force_encoding("UTF-8")
    end

    sig { params(data_str: String).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
    def parsed_json_message(data_str)
      Oj.load(data_str, mode: :compat, symbol_keys: true, cache_keys: true)
    rescue StandardError => _e
      raise ParserError, "Unable to parse JSON, payload: `#{data_str}`"
    end
  end
end
