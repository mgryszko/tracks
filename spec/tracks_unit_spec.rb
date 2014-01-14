require 'spec_helper'

describe Waypoint do
  it 'can be created with latitude and longitute' do
    expect(Waypoint.new(1.0, 4.0).lat).to eq(1.0)
    expect(Waypoint.new(1.0, 4.0).lon).to eq(4.0)
  end 
end
