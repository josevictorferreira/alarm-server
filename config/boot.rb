# frozen_string_literal: true

require 'dry-auto_inject'
require_relative 'application'

Import = Dry::AutoInject(Application)

Dir[File.join(__dir__, '../lib/alarm_server/**/*.rb')].sort.each { |f| require f }
