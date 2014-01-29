#!/usr/bin/env ruby

require_relative 'lib/tracks'

raise ArgumentError, 'At least one track file must be given' if ARGV.empty?

repository = TrackGpxRepository.new
calculator = HaversineDistanceCalculator.new
calculate = CalculateTrackDistance.new(repository, calculator)

ARGV.each do |file_name|
  puts "Calculating total distance of #{file_name}..."
  total_distance = calculate.execute(file_name)
  puts "It is #{total_distance} m"
 end
