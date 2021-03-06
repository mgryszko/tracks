require_relative '../lib/tracks'
require_relative '../lib/tracks_infrastructure'
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

module PointFixture
  def point_2d(lat, lon)
    Point.new(lat, lon, nil, nil)
  end
end

