
#
# For some reason .blank? isn't working here
# This is an issue for rspec only
# undefined method `blank?' for "type":String
#
module CustomBlank
  def blank?
    self == nil || self == '' || self == ' '
  end
end
class Array
  def blank?
    self == []
  end
end
class NilClass
  include CustomBlank
end
class File
  include CustomBlank
end
class String
  include CustomBlank
end

require 'hancock'
require 'nokogiri'
require_relative 'support/configs'
require_relative 'support/incorrect_configs'
require_relative 'support/variables'

SPEC_ROOT = File.expand_path '../', __FILE__

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end