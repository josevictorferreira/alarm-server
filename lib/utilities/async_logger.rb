# frozen_string_literal: true

require 'async'
require 'async/queue'

module Utilities
  class AsyncLogger
    def initialize(output = $stdout, level = :info)
      @queue = Async::Queue.new
      @output = output.downcase
      @level = level

      @task = Async do
        process_log_queue
      end
    end

    def debug(message)
      case @level
      when :debug
        @queue.enqueue([:debug, message])
      end
    end

    def info(message)
      case @level
      when :debug, :info
        @queue.enqueue([:info, message])
      end
    end

    def warn(message)
      case @level
      when :debug, :info, :warn
        @queue.enqueue([:warn, message])
      end
    end

    def error(message)
      case @level
      when :debug, :info, :warn, :error
        @queue.enqueue([:error, message])
      end
    end

    def fatal(message)
      case @level
      when :debug, :info, :warn, :error, :fatal
        @queue.enqueue([:fatal, message])
      end
    end

    def close
      return unless @task.running?

      @queue.enqueue(nil)
      @task.wait
    end

    private

    def process_log_queue
      while (log = @queue.dequeue)
        break if log.nil?

        case @output
        when 'stdout', 'stderr'
          print(format_log_line(log))
        else
          write_to_file!(format_log_line(log))
        end
      end
    end

    def format_log_line(log)
      level, message = log

      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      "[#{timestamp}] #{level.to_s.upcase} => #{message}\n"
    end

    def write_to_file!(log_line)
      FileUtils.mkdir_p(File.dirname(@output)) unless Dir.exist?(File.dirname(@output))
      File.open(@output, 'a') do |file|
        file.write(log_line)
      end
    end
  end
end
