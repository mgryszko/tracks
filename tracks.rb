class Waypoint
  attr_reader :lat, :lon

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end
end

class HaversineDistanceCalculator
  require 'geo-distance'

  def initialize
    GeoDistance.default_algorithm = :haversine
  end

  def distanceBetween(p1, p2)
    GeoDistance.distance(p1.lat, p1.lon, p2.lat, p2.lon).kms_to(:meters)
  end
end
