require 'spec_helper'

describe Waypoint do
  it 'can be created with latitude and longitute' do
    expect(Waypoint.new(1.0, 4.0).lat).to eq(1.0)
    expect(Waypoint.new(1.0, 4.0).lon).to eq(4.0)
  end 
end

describe TrackDistanceCalculator do
  before(:each) do
    @calc = double()
  end

  it 'track consisting of a single point has zero distance' do
    p1 = Waypoint.new(1.0, 2.0)
    track = Track.new(p1)
    calculator = TrackDistanceCalculator.new(@calc)

    expect(calculator.total_distance(track)).to eq(0.0)
  end

  it 'calculates total distance of a two-point track' do
    p1, p2 = Waypoint.new(1.0, 2.0), Waypoint.new(2.0, 3.0)
    track = Track.new(p1, p2)
    @calc.should_receive(:distance_between).with(p1, p2).and_return(1.0)
    calculator = TrackDistanceCalculator.new(@calc)

    expect(calculator.total_distance(track)).to eq(1.0)
  end

  it 'calculates total distance of a multi-point track' do
    p1, p2, p3 = Waypoint.new(1.0, 2.0), Waypoint.new(2.0, 3.0), Waypoint.new(3.0, 4.0)
    track = Track.new(p1, p2, p3)
    @calc.should_receive(:distance_between).with(p1, p2).and_return(1.0)
    @calc.should_receive(:distance_between).with(p2, p3).and_return(2.0)
    calculator = TrackDistanceCalculator.new(@calc)

    expect(calculator.total_distance(track)).to eq(3.0)
  end
end
