# frozen_string_literal: true

source 'https://rubygems.org'

gem 'async', '~> 2.23'
gem 'io-endpoint', '~> 0.15.2'

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'rubocop', '~> 1.75', groups: %i[development test]
  gem 'rubocop-performance', '~> 1.24', groups: %i[development test]
  gem 'solargraph', '~> 0.53.3'
end
