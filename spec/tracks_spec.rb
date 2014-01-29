require 'spec_helper'

describe CalculateTrackDistance do
  points = [
    [38.65760, -0.10489],  
    [38.70632, -0.10808],  
    [38.72474, -0.05631],  
    [38.76751, -0.05660],  
    [38.82411, -0.07796],  
    [38.84112, -0.11785],  
    [38.87587, -0.09626],  
    [38.91885, -0.11806],  
    [38.83950, 0.11278],  
  ].collect { |c| Point.new(*c) }

  before(:each) do
    @repository = double()
    @calculator = CalculateTrackDistance.new(@repository, HaversineDistanceCalculator.new)
  end

  it 'calculates total track distance' do
    track = Track.new(*points)
    @repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

    distance = @calculator.calculate('track.gpx')

    expect(distance).to be_within(100).of(56970)
  end
end

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

