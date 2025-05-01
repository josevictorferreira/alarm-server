# typed: false
# frozen_string_literal: true

require "dry-auto_inject"
require "faraday"

module Clients
  class NtfyClient
    PRIORITIES = {
      min: 1,
      low: 2,
      default: 3,
      high: 4,
      max: 5,
    }.freeze

    def initialize(url:, topic:)
      @url = url
      @topic = topic
      @connection = Faraday.new(url: url) do |conn|
        conn.adapter(Faraday.default_adapter)
        conn.options.timeout = 3
        conn.response(:json, content_type: /\bjson$/)
      end
    end

    def send_notification(title, message, priority: :default, tags: [])
      response = @connection.post("/#{@topic}") do |req|
        req.body = message
        req.headers["Content-Type"] = "text/plain"
        req.headers["Title"] = title
        req.headers["Priority"] = PRIORITIES[priority].to_s if priority
        req.headers["Tags"] = tags.join(",") unless tags.empty?
      end
      response.success?
    end
  end
end
