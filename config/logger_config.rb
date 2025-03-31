# frozen_string_literal: true

require 'dry-configurable'

module LoggerConfig
  extend Dry::Configurable

  setting :level, default: ENV.fetch('LOG_LEVEL', 'debug').downcase.to_sym
  setting :output, default: ENV.fetch('LOG_OUTPUT', 'stdout').downcase
end
