
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
      each_adjacent_points { |section| update_statistics(stats, section, calculator) }
      stats
    end

    private

    def each_adjacent_points(&block)
      @points.each_cons(2).each(&block)
    end

    def update_statistics(stats, section, calculator)
        dist_so_far = stats.distance
        v_avg_so_far = stats.avg_speed
        dist, t, v, ascent = section_statistics(section, calculator)
        stats.distance += dist
        stats.ascent += ascent
        stats.total_time += t
        stats.avg_speed = avg_speed(v_avg_so_far, v, dist_so_far, dist)
    end

    def section_statistics(section, calculator)
      from, to = section[0], section[1]
      dist = calculator.distance_between(from, to)
      t = time_between(from, to)
      v = dist / t
      ascent = ascent(from, to)
      [dist, t, v, ascent]
    end

    def time_between(from, to)
      to.time - from.time
    end

    def ascent(from, to)
      (to.elevation - from.elevation if to.elevation > from.elevation) || 0.0
    end

    def avg_speed(v_avg_so_far, v, dist_so_far, dist)
        if v_avg_so_far == 0
          v
        else
          v_avg_so_far * v * (dist_so_far + dist) / 
            (dist_so_far * v + dist * v_avg_so_far)
        end
    end
  end


  class Point
    attr_reader :lat, :lon, :elevation, :time

    def initialize(lat, lon, elevation, time)
      raise ArgumentError, "latitude must be between -90.0 and 90.0 degrees" unless lat.between?(-90.0, 90.0)
      raise ArgumentError, "longitude must be between -180.0 and 180.0 degrees" unless lon.between?(-180.0, 180.0)
      @lat = lat
      @lon = lon
      @elevation = elevation
      @time = time
    end

    def ==(other)
      @lat == other.lat && @lon == other.lon && @elevation == other.elevation && @time == other.time
    end

    def to_s
      "(#{@lat},#{@lon})@#{@elevation}m"
    end
  end


  class TrackStatistics < Struct.new(:distance, :ascent, :avg_speed, :total_time)
    def self.empty
      TrackStatistics.new(0.0, 0.0, 0.0, 0)
    end
  end
end
