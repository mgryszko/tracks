require 'spec_helper'

describe CalculateTrackStatistics do
  let(:repository) { double() }
  let(:calculator) do
    CalculateTrackStatistics.new(repository, HaversineDistanceCalculator.new)
  end

  context 'multipoint track' do
    let(:points) do 
      [
        [38.65760, -0.10489, 186.6, '2011-08-21T07:39:59'],
        [38.70632, -0.10808, 523.1, '2011-08-21T08:22:40'],
        [38.72474, -0.05631, 600.0, '2011-08-21T08:32:13'],
        [38.76751, -0.05660, 233.3, '2011-08-21T08:40:57'],
        [38.82411, -0.07796, 202.5, '2011-08-21T08:58:32'],
        [38.84112, -0.11785, 91, '2011-08-21T09:26:36'],
        [38.87587, -0.09626, 17, '2011-08-21T09:55:05'],
        [38.91885, -0.11806, 17, '2011-08-21T10:05:30'],
        [38.83950, 0.11278, 3, '2011-08-21T12:04:25'],
      ].collect do |lat, lon, altitude, time|
        Point.new(lat, lon, altitude, Time.iso8601(time))
      end
    end

    it 'calculates track statistics' do
      track = Track.new(*points)
      repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = calculator.execute('track.gpx')

      expect(stats.distance).to be_within(100).of(56970)
      expect(stats.ascent).to eq(413.4)
      expect(stats.avg_speed).to be_within(0.05).of(3.59)
      expect(stats.total_time).to eq(15866)
    end
  end

  context 'one point track' do
    it 'yields empty statistics' do
      track = Track.new(Point.new(38.65760, -0.10489, 186.6, Time.iso8601('2011-08-21T07:39:59')))
      repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = calculator.execute('track.gpx')

      expect(stats.distance).to eq(0.0)
      expect(stats.ascent).to eq(0.0)
      expect(stats.avg_speed).to eq(0.0)
      expect(stats.total_time).to eq(0)
    end
  end

  context 'zero point track' do
    it 'yields empty statistics' do
      track = Track.new()
      repository.should_receive(:read_track_from).with('track.gpx').and_return(track)

      stats = calculator.execute('track.gpx')

      expect(stats.distance).to eq(0.0)
      expect(stats.ascent).to eq(0.0)
      expect(stats.avg_speed).to eq(0.0)
      expect(stats.total_time).to eq(0)
    end
  end
end


describe Point do
  include PointFixture

  context 'out of range latitude' do
    let(:lon) { 0.0 }

    it 'raise ArgumentError' do
      expect { point_2d(-90.00001, lon) }.to raise_error(ArgumentError)
      expect { point_2d(-90.0, lon) }.not_to raise_error
      expect { point_2d(90.0, lon) }.not_to raise_error
      expect { point_2d(90.00001, lon) }.to raise_error(ArgumentError)
    end
  end

  context 'out-of range longitude' do
    let(:lon) { 0.0 }

    it 'raise ArgumentError' do
      expect { point_2d(lon, -180.00001) }.to raise_error(ArgumentError)
      expect { point_2d(lon, -180.0) }.not_to raise_error
      expect { point_2d(lon, 180.0) }.not_to raise_error
      expect { point_2d(lon, 180.00001) }.to raise_error(ArgumentError)
    end
  end
end

