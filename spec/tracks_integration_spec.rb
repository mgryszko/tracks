require 'spec_helper'

describe HaversineDistanceCalculator do
  cases = {
    [Point.new(42.32623, -5.27950), Point.new(42.32586, -5.28069)] => 106.0,
    [Point.new(40.40889, -3.60970), Point.new(40.40882, -3.60984)] => 14.0,
    [Point.new(38.69607,  0.10314), Point.new(38.69580,  0.10364)] => 53.0,
  }

  cases.each do |ps, distance|
    it "calculates distance between #{ps[0]} and #{ps[1]}" do
      calc = HaversineDistanceCalculator.new

      expect(calc.distance_between(ps[0], ps[1])).to be_within(0.5).of(distance)
    end
  end
end

describe TrackGpxRepository do
  include FileMatchers

  before(:each) do
    @repository = TrackGpxRepository.new
  end

  it "reads a track from a GPX file" do
    track_file = 'spec/fixtures/track1.gpx'
    expect(track_file).to be_file

    track = @repository.read_track_from(track_file)

    expect(track.points.size).to eq(1398)
    expect(track.points[0]).to eq(Point.new(38.657604977488518, -0.10489197447896))
    expect(track.points[1397]).to eq(Point.new(38.839498981833458, 0.112783033400774))
  end
end
