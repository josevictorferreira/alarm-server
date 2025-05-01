# typed: false
# frozen_string_literal: true

module NtfyConfig
  extend Dry::Configurable

  setting :enabled, default: ENV.fetch("NTFY_ENABLED", false) == "true"
  setting :url, default: ENV.fetch("NTFY_URL", nil)
  setting :topic, default: ENV.fetch("NTFY_TOPIC", nil)
end
