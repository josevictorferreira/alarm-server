# typed: false
# frozen_string_literal: true

require "dry-configurable"

module MqttConfig
  extend Dry::Configurable

  setting :url, default: ENV.fetch("MQTT_URL", "mqtt://localhost:1883")
  setting :topic, default: ENV.fetch("MQTT_TOPIC", "alarms")
  setting :client_id, default: ENV.fetch("MQTT_CLIENT_ID", "alarm_server")
end
