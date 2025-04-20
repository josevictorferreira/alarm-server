# frozen_string_literal: true

require 'dry-auto_inject'
require 'faraday'

module Clients
  class NtfyClient
    def initialize(url:, topic:)
      @url = url
      @topic = topic
      @connection = Faraday.new(url: url) do |conn|
        conn.adapter Faraday.default_adapter
        conn.options.timeout = 3
        conn.headers['Content-Type'] = 'text/plain'
        conn.response :json, content_type: /\bjson$/
      end
    end

    def send_notification(message)
      response = @connection.post("/#{@topic}") do |req|
        req.body = message
      end
      response.success?
    end
  end
end
