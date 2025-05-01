# typed: false
# frozen_string_literal: true

require "dry-configurable"

module ServerConfig
  extend Dry::Configurable

  setting :address, default: ENV.fetch("ADDRESS", "0.0.0.0")
  setting :port, default: ENV.fetch("PORT", 8888).to_i
end
