require 'hancock'
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
