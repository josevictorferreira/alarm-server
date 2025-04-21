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
        notification_message: parsed_message(parsed_data),
        parsed_data: parsed_data,
        raw_message: raw_data
      )
    end

    private

    def parsed_message(data)
      return nil if data[:Type] != 'Alarm' || data[:Status] != 'Start' || data[:Event] != 'HumanDetect'

      notification_data = NotificationData.new(
        title: 'Human detected!',
        device_name: 'ICSee Cam',
        device_address: data[:Address],
        device_channel: data[:Channel],
        formatted_time: Time.parse(data[:StartTime]).strftime('%Y-%m-%d %H:%M:%S'),
        status: data[:Status]
      )

      rendered_template('base_notification', notification_data)
    end
  end
end
