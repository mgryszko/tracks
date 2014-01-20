require 'spec_helper'

describe HaversineDistanceCalculator do
  cases = {
    [Waypoint.new(42.32623, -5.27950), Waypoint.new(42.32586, -5.28069)] => 106.0,
    [Waypoint.new(40.40889, -3.60970), Waypoint.new(40.40882, -3.60984)] => 14.0,
    [Waypoint.new(38.69607,  0.10314), Waypoint.new(38.69580,  0.10364)] => 53.0,
  }

  cases.each do |ps, distance| 
    it "calculates distance between #{ps[0]} and #{ps[1]}" do
      calc = HaversineDistanceCalculator.new
      expect(calc.distance_between(ps[0], ps[1])).to be_within(0.5).of(distance)
    end 
  end
end
