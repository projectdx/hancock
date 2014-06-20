# encoding: UTF-8
require 'simplecov'
SimpleCov.start

require 'hancock'
require 'nokogiri'
require 'valid_attribute'
require 'webmock/rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include PathHelper
  config.include RequestStubHelper
end