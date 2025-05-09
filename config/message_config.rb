# typed: false
# frozen_string_literal: true

require "dry/configurable"

module MessageConfig
  extend Dry::Configurable

  # The values in the `type_field` that will be used to filter messages to be forwarded.
  setting :filters, default: ENV.fetch("MESSAGE_FILTERS", "alarm,log").split(",").map { |x| x.strip.downcase }

  # The default parser class to be used for parsing messages.
  setting :parser, default: ENV.fetch("MESSAGE_PARSER", "icsee"), constructor: proc { |default_parser|
    require_relative "../lib/parsers/#{default_parser}_parser"

    Object.const_get("Parsers::#{default_parser.split.map(&:capitalize).join}Parser")
  }

  setting :priority, default: ENV.fetch("MESSAGE_PRIORITY", "default").to_sym
end
