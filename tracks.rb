class Waypoint
  attr_reader :lat, :lon

  def initialize(lat, lon)
    # TODO check lat and lon ranges 
    @lat = lat
    @lon = lon
  end
end

class Track
  attr_reader :points

  def initialize(*points)
    # TODO track must have at least 2 points - really?
    @points = points
  end

  def inject_on_adjacent(initial, &block)
    @points.each_cons(2).inject(initial, &block)
  end
end

class TrackDistanceCalculator
  def initialize(calculator)
    @calculator = calculator
  end

  def total_distance(track)
    track.inject_on_adjacent(0.0) do |sum, pair|
      from, to = pair
      sum + @calculator.distance_between(from, to)
    end
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
