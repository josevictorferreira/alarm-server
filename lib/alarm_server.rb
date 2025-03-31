# frozen_string_literal: true

require_relative '../config/boot'
require_relative 'alarm_server/message_handler'
require 'async'
require 'debug'

module AlarmServer
  Import = ::Import
  App = ::Application

  def self.run!
    Sync do
      App[:tcp_server].start(
        address: App[:server_address],
        handler: MessageHandler,
        logger: App[:logger]
      )
    end
  end
end
