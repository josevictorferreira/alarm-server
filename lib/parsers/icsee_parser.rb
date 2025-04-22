# frozen_string_literal: true

require_relative 'base'
require 'securerandom'

module Parsers
  class IcseeParser < Base
    def parse
      MessageData.new(
        message_id: SecureRandom.uuid_v7,
        device_id: parsed_data[:SerialID],
        type: parsed_data[:Type].downcase,
        time: Time.parse(parsed_data[:StartTime]),
        notification_data: notification_data,
        parsed_data: parsed_data,
        raw_message: raw_data
      )
    end

    private

    def notification_data
      @notification_data ||= NotificationData.new(
        title: 'Human Detected!',
        priority: priority,
        tags: %w[adult movie_camera],
        message: parsed_message(parsed_data)
      )
    end

    def parsed_message(data)
      return nil if data[:Type] != 'Alarm' || data[:Status] != 'Start' || data[:Event] != 'HumanDetect'

      notification_content_data = NotificationContentData.new(
        device_name: 'ICSee Cam',
        device_address: data[:Address],
        device_channel: data[:Channel],
        formatted_time: Time.parse(data[:StartTime]).strftime('%Y-%m-%d %H:%M:%S'),
        status: data[:Status]
      )

      rendered_template('base_notification', notification_content_data)
    end
  end
end
