require 'spec_helper'

describe Waypoint do
  it 'out-of range latitudes raise ArgumentError' do
    expect { Waypoint.new(-90.00001, 0.0) }.to raise_error(ArgumentError)
    expect { Waypoint.new(-90.0, 0.0) }.not_to raise_error
    expect { Waypoint.new(90.0, 0.0) }.not_to raise_error
    expect { Waypoint.new(90.00001, 0.0) }.to raise_error(ArgumentError)
  end 

  it 'out-of range longitudes raise ArgumentError' do
    expect { Waypoint.new(0.0, -180.00001) }.to raise_error(ArgumentError)
    expect { Waypoint.new(0.0, -180.0) }.not_to raise_error
    expect { Waypoint.new(0.0, 180.0) }.not_to raise_error
    expect { Waypoint.new(0.0, 180.00001) }.to raise_error(ArgumentError)
  end 
end

describe TrackDistanceCalculator do
  before(:each) do
    @calc = double()
  end

  it 'empty track has zero distance' do
    track = Track.new()
    calculator = TrackDistanceCalculator.new(@calc)

    expect(calculator.total_distance(track)).to eq(0.0)
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
