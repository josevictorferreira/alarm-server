# typed: false
# frozen_string_literal: true

require "spec_helper"
require "utilities/tcp_server"
require "async"
require "json"

RSpec.describe(Utilities::TcpServer) do
  let(:port) { 8080 }
  let(:address) { "localhost:#{port}" }
  let(:logger) { instance_double(Logger, info: nil, debug: nil, error: nil) }
  let(:handler) { instance_double(Handler) }
  let(:server) { described_class.new(address: address, handler: handler, logger: logger) }
  let(:message) { { "key" => "value" }.to_json }

  describe "#initialize" do
    it "sets the address, handler, and logger" do
      expect(server.address).to(eq(address))
      expect(server.handler).to(eq(handler))
      expect(server.logger).to(eq(logger))
    end
  end

  describe "#start" do
    it "starts the server and logs the endpoint" do
      expect(logger).to(receive(:info).with(/Listening/))

      # Mock the endpoint to prevent actual server start
      endpoint = instance_double(IO::Endpoint::AddressEndpoint)
      allow(IO::Endpoint::AddressEndpoint).to(receive(:new).with(address).and_return(endpoint))
      allow(endpoint).to(receive(:accept))

      server.start
    end
  end

  describe ".start" do
    it "creates a new instance and starts it" do
      server_instance = instance_double(described_class)
      expect(described_class).to(receive(:new).with(
        address: address,
        handler: handler,
        logger: logger,
      ).and_return(server_instance))
      expect(server_instance).to(receive(:start))

      described_class.start(address: address, handler: handler, logger: logger)
    end
  end

  describe "#async_handle_socket" do
    let(:socket) { instance_double(Async::IO::Socket) }
    let(:address) { "127.0.0.1" }
    let(:task) { instance_double(Async::Task) }

    before do
      allow(task).to(receive(:with_timeout).and_yield)
      allow(socket).to(receive(:close))
    end

    context "when processing succeeds" do
      before do
        allow(server).to(receive(:read_message).with(socket).and_return(message))
        allow(handler).to(receive(:call).with(socket, message))
      end

      it "processes the message and closes the socket" do
        expect(handler).to(receive(:call).with(socket, message))
        expect(logger).to(receive(:debug).with(/Connection closed with #{address}/))

        server.send(:async_handle_socket, task, socket, address)
      end
    end

    context "when an error occurs" do
      let(:error) { StandardError.new("Test error") }

      before do
        allow(server).to(receive(:read_message).with(socket).and_raise(error))
        allow(error).to(receive(:backtrace).and_return(["backtrace"]))
      end

      it "logs the error and closes the socket" do
        expect(logger).to(receive(:error)
          .with("Connection with 127.0.0.1 exited \nError: Test error\n Backtrace: [\"backtrace\"]"))
        expect(logger).to(receive(:debug)
          .with(/Connection closed with #{address}/))

        server.send(:async_handle_socket, task, socket, address)
      end
    end
  end

  describe "#read_message" do
    let(:socket) { instance_double(Async::IO::Socket) }

    context "when the message ends with a newline" do
      before do
        allow(socket).to(receive(:readpartial).with(1024).and_return("{\"key\":\"value\"}\n"))
      end

      it "reads the message and parses it" do
        expect(server).to(receive(:parse_message).with("{\"key\":\"value\"}\n").and_return(message))

        result = server.send(:read_message, socket)
        expect(result).to(eq(message))
      end
    end

    context "when the message is received in chunks" do
      before do
        allow(socket).to(receive(:readpartial).with(1024).and_return('{"key":', "\"value\"}\n"))
      end

      it "reads all chunks until newline and parses the message" do
        expect(server).to(receive(:parse_message).with("{\"key\":\"value\"}\n").and_return(message))

        result = server.send(:read_message, socket)
        expect(result).to(eq(message))
      end
    end

    context "when EOFError is raised" do
      before do
        allow(socket).to(receive(:readpartial).with(1024).and_raise(EOFError))
        allow(logger).to(receive(:debug).with("Connection closed by client").and_return("{}"))
      end

      it "logs the connection closure and returns empty JSON" do
        expect(logger).to(receive(:debug).with("Connection closed by client"))

        result = server.send(:read_message, socket)
        expect(result).to(eq("{}"))
      end
    end
  end

  describe "#parse_message" do
    context "when the message starts with JSON" do
      let(:full_message) { '{"key":"value"}' }

      it "returns the JSON part of the message" do
        result = server.send(:parse_message, full_message)
        expect(result).to(eq(full_message))
      end
    end

    context "when the message has a prefix before JSON" do
      let(:full_message) { 'PREFIX{"key":"value"}' }

      it "extracts and returns only the JSON part" do
        result = server.send(:parse_message, full_message)
        expect(result).to(eq('{"key":"value"}'))
      end
    end

    context "when the message has no JSON" do
      let(:full_message) { "NO_JSON_HERE" }

      it "returns the full message" do
        result = server.send(:parse_message, full_message)
        expect(result).to(eq("NO_JSON_HERE"))
      end
    end

    context "when the message has invalid UTF-8 characters" do
      let(:full_message) { "{\xBA\"key\":\"value\"}" }

      it "replaces invalid characters and returns the message" do
        result = server.send(:parse_message, full_message)
        expect(result).not_to(include("\xBA"))
      end
    end

    context "when the message ends with a newline" do
      let(:full_message) { "{\"key\":\"value\"}\n" }

      it "removes the trailing newline" do
        result = server.send(:parse_message, full_message)
        expect(result).to(eq('{"key":"value"}'))
      end
    end
  end

  describe "integration test" do
    it "handles a client connection and processes messages" do
      # This would be a more complex test that actually starts the server
      # and connects a client, but for simplicity we'll mock most of it

      endpoint = instance_double(IO::Endpoint::AddressEndpoint)
      socket = instance_double(Async::IO::Socket)
      client_address = instance_double(Async::IO::Address, ip_address: "127.0.0.1")

      allow(IO::Endpoint::AddressEndpoint).to(receive(:new).with(address).and_return(endpoint))
      allow(endpoint).to(receive(:accept).and_yield(socket, client_address))
      allow(logger).to(receive(:info))
      allow(logger).to(receive(:debug))

      expect(server).to(receive(:async_handle_socket).with(an_instance_of(Async::Task), socket, "127.0.0.1"))

      server.start
    end
  end
end
