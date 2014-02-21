require 'nokogiri'

module Tracks
  class TrackGpxRepository

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
