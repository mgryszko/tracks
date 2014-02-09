require 'spec_helper'

describe CalculateTrackStatistics do
  before(:each) do
    @repository = double()
    @calculator = CalculateTrackStatistics.new(@repository, HaversineDistanceCalculator.new)
  end

  context 'multipoint track' do
    points = [
      [38.65760, -0.10489, 186.6],
      [38.70632, -0.10808, 523.1],
      [38.72474, -0.05631, 600.0],
      [38.76751, -0.05660, 233.3],
      [38.82411, -0.07796, 202.5],
      [38.84112, -0.11785, 91],
      [38.87587, -0.09626, 17],
      [38.91885, -0.11806, 17],
      [38.83950, 0.11278, 3],
    ].collect { |c| Point.new(*c) }

    it 'calculates track statistics' do
      track = Track.new(*points)
      @repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = @calculator.execute('track.gpx')

      expect(stats.distance).to be_within(100).of(56970)
      expect(stats.ascent).to eq(413.4)
    end
  end

  context 'one point track' do
    it 'yields empty statistics' do
      track = Track.new(Point.new(38.65760, -0.10489, 186.6))
      @repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = @calculator.execute('track.gpx')

      expect(stats.distance).to eq(0.0)
      expect(stats.ascent).to eq(0.0)
    end
  end

  context 'zero point track' do
    it 'yields empty statistics' do
      track = Track.new()
      @repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = @calculator.execute('track.gpx')

      expect(stats.distance).to eq(0.0)
      expect(stats.ascent).to eq(0.0)
    end
  end
end


describe Point do
  it 'out-of range latitudes raise ArgumentError' do
    expect { Point.new(-90.00001, 0.0, 0.0) }.to raise_error(ArgumentError)
    expect { Point.new(-90.0, 0.0, 0.0) }.not_to raise_error
    expect { Point.new(90.0, 0.0, 0.0) }.not_to raise_error
    expect { Point.new(90.00001, 0.0, 0.0) }.to raise_error(ArgumentError)
  end

  it 'out-of range longitudes raise ArgumentError' do
    expect { Point.new(0.0, -180.00001, 0.0) }.to raise_error(ArgumentError)
    expect { Point.new(0.0, -180.0, 0.0) }.not_to raise_error
    expect { Point.new(0.0, 180.0, 0.0) }.not_to raise_error
    expect { Point.new(0.0, 180.00001, 0.0) }.to raise_error(ArgumentError)
  end
end

