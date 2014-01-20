require 'spec_helper'

describe Point do
  it 'out-of range latitudes raise ArgumentError' do
    expect { Point.new(-90.00001, 0.0) }.to raise_error(ArgumentError)
    expect { Point.new(-90.0, 0.0) }.not_to raise_error
    expect { Point.new(90.0, 0.0) }.not_to raise_error
    expect { Point.new(90.00001, 0.0) }.to raise_error(ArgumentError)
  end 

  it 'out-of range longitudes raise ArgumentError' do
    expect { Point.new(0.0, -180.00001) }.to raise_error(ArgumentError)
    expect { Point.new(0.0, -180.0) }.not_to raise_error
    expect { Point.new(0.0, 180.0) }.not_to raise_error
    expect { Point.new(0.0, 180.00001) }.to raise_error(ArgumentError)
  end 
end

describe TrackDistanceCalculator do
  before(:each) do
    @calc = double()
    @calculator = TrackDistanceCalculator.new(@calc)
    @p1, @p2, @p3 = Point.new(1.0, 2.0), Point.new(2.0, 3.0), Point.new(3.0, 4.0)
  end

  it 'empty track has zero distance' do
    track = Track.new()

    expect(@calculator.total_distance(track)).to eq(0.0)
  end

  it 'track consisting of a single point has zero distance' do
    track = Track.new(@p1)

    expect(@calculator.total_distance(track)).to eq(0.0)
  end

  it 'calculates total distance of a two-point track' do
    track = Track.new(@p1, @p2)
    @calc.should_receive(:distance_between).with(@p1, @p2).and_return(1.0)

    expect(@calculator.total_distance(track)).to eq(1.0)
  end

  it 'calculates total distance of a multi-point track' do
    track = Track.new(@p1, @p2, @p3)
    @calc.should_receive(:distance_between).with(@p1, @p2).and_return(1.0)
    @calc.should_receive(:distance_between).with(@p2, @p3).and_return(2.0)

    expect(@calculator.total_distance(track)).to eq(3.0)
  end
end
