module Tracks
  class CalculateTrackStatistics
    def initialize(track_repository, calculator)
      @repository = track_repository
      @calculator = calculator
    end

    def execute(file_name)
      track = @repository.read_track_from(file_name)
      track.statistics(@calculator)
    end
  end


  class Track
    attr_reader :points

    def initialize(*points)
      @points = points
    end

    def statistics(calculator)
      stats = TrackStatistics.empty
      each_adjacent_points do |pair|
        from, to = pair
        stats.distance += calculator.distance_between(from, to)
        stats.ascent += ascent(from, to) 
      end
      stats
    end

    private 

    def each_adjacent_points(&block)
      @points.each_cons(2).each(&block)
    end

    def ascent(from, to)
      (to.elevation - from.elevation if to.elevation > from.elevation) || 0.0
    end
  end


  class Point
    attr_reader :lat, :lon, :elevation

    def initialize(lat, lon, elevation)
      raise ArgumentError, "latitude must be between -90.0 and 90.0 degrees" unless lat.between?(-90.0, 90.0)
      raise ArgumentError, "longitude must be between -180.0 and 180.0 degrees" unless lon.between?(-180.0, 180.0)
      @lat = lat
      @lon = lon
      @elevation = elevation
    end

    def ==(other)
      @lat == other.lat && @lon == other.lon && @elevation == other.elevation
    end

    def to_s
      "(#{@lat},#{@lon})@#{@elevation}m"
    end
  end


  class TrackStatistics < Struct.new(:distance, :ascent)
    def self.empty
      TrackStatistics.new(0.0, 0.0)
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
      Point.new(lat_from(trackpoint), lon_from(trackpoint), elevation_from(trackpoint))
    end

    def lat_from(trackpoint)
      trackpoint['lat'].to_f
    end

    def lon_from(trackpoint)
      trackpoint['lon'].to_f
    end

    def elevation_from(trackpoint)
      trackpoint.xpath('xmlns:ele').text.to_f
    end
  end
end
