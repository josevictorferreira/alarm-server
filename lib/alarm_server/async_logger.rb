# frozen_string_literal: true

require 'async'
require 'async/queue'

# This class is a simple logger that writes log messages to a file or to the standard output.
class AsyncLogger
  def initialize(output = $stdout, level = :info)
    @queue = Async::Queue.new
    @output = output
    @level = level

    @task = Async do
      process_log_queue
    end
  end

  def debug(message)
    @queue.enqueue([:debug, message]) if @level == :debug
  end

  def info(message)
    @queue.enqueue([:info, message]) if  %i[debug info].include?(@level)
  end

  def warn(message)
    @queue.enqueue([:warn, message]) if %i[debug info warn].include?(@level)
  end

  def error(message)
    @queue.enqueue([:error, message]) if %i[debug info warn error].include?(@level)
  end

  def fatal(message)
    @queue.enqueue([:fatal, message]) if %i[debug info warn error fatal].include?(@level)
  end

  def close
    @queue.enqueue(nil)
    @task.wait
  end

  private

  def process_log_queue
    while (log = @queue.dequeue)
      break if log.nil?

      level, message = log

      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      log_line = "[#{timestamp}] #{level.to_s.upcase}: #{message}"

      @output.print(log_line) && return if @output == $stdout || @output == $stderr

      write_to_file! log_line
    end
  end

  def write_to_file!(log_line)
    FileUtils.mkdir_p(File.dirname(@outputl)) unless Dir.exist?(File.dirname(@output))
    File.open(@output, 'a') do |file|
      file.write(log_line)
    end
  end
end
