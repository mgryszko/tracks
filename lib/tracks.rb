class CalculateTrackDistance
  def initialize(track_repository, calculator)
    @repository = track_repository
    @calculator = calculator
  end

  def execute(file_name)
    track = @repository.read_track_from(file_name)
    track.total_distance(@calculator)
  end
end

class Point
  attr_reader :lat, :lon

  def initialize(lat, lon)
    raise ArgumentError, "latitude must be between -90.0 and 90.0 degrees" unless lat.between?(-90.0, 90.0)
    raise ArgumentError, "longitude must be between -180.0 and 180.0 degrees" unless lon.between?(-180.0, 180.0)
    @lat = lat
    @lon = lon
  end

  def ==(other)
    self.lat == other.lat && self.lon == other.lon
  end

  def to_s
    "(#{lat},#{lon})"
  end
end


class Track
  attr_reader :points

  def initialize(*points)
    @points = points
  end

  def total_distance(calculator)
    inject_on_adjacent(0.0) do |sum, pair|
      from, to = pair
      sum + calculator.distance_between(from, to)
    end
  end

  private 

  def inject_on_adjacent(initial, &block)
    @points.each_cons(2).inject(initial, &block)
  end
end


class HaversineDistanceCalculator
  require 'geo-distance'

  def initialize
    GeoDistance.default_algorithm = :haversine
  end

  def distance_between(p1, p2)
    GeoDistance.distance(p1.lat, p1.lon, p2.lat, p2.lon).kms_to(:meters)
  end
end

class TrackGpxRepository
  require 'nokogiri'

  def read_track_from(file)
    File.open(file) do |f|
      doc = parse(f)
      trackpoints = all_trackpoints_in(doc)
      create_track_from(trackpoints)
    end
  end

  private

  def parse(file)
    Nokogiri::XML(file)
  end

  def all_trackpoints_in(doc)
    doc.xpath('//xmlns:trkpt')
  end

  def create_track_from(trackpoints)
    points = []
    trackpoints.each do |tp|
      points << to_point(tp)
    end
    Track.new(*points)
  end

  def to_point(trackpoint)
    Point.new(trackpoint['lat'].to_f, trackpoint['lon'].to_f)
  end
end
