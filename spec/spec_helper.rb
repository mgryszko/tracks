require_relative '../lib/tracks'
include Tracks

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

module FileMatchers
  extend RSpec::Matchers::DSL

  matcher :be_file do |expected|
    match {|actual| File.exists?(actual)}
  end
end

