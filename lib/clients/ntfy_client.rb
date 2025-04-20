# frozen_string_literal: true

require 'dry-auto_inject'
require 'faraday'

module Clients
  class NtfyClient
    def initialize(url:, topic:)
      @url = url
      @topic = topic
      @connection = Faraday.new(url: url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter :net_http
        conn.options.timeout = 3
      end
    end

    def send_notification(message)
      response = @connection.post("/#{@topic}", { message: message })
      response.success?
    end
  end
end
