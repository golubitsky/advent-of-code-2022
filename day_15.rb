# frozen_string_literal: true

require 'set'

def debug_puts(s, indent = 0)
  puts "#{"\t" * indent}#{s}" if DEBUG_PUTS_ENABLED
end

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map { |line| parsed_line(line) }
  end

  def parsed_line(line)
    sensor_x, sensor_y, closest_beacon_x, closest_beacon_y = line.scan(/-?\d+/).map(&:to_i)

    {
      sensor: { x: sensor_x, y: sensor_y },
      closest_beacon: { x: closest_beacon_x, y: closest_beacon_y }
    }
  end
end

module Solution
  extend self

  def solution(state:, target_y:)
    beacon_cannot_be_at = Set.new
    beacons = state.map { |row| row[:closest_beacon] }.to_set

    state.each do |sensor:, closest_beacon:|
      debug_puts "\nsensor #{sensor} closest #{closest_beacon}"
      distance = manhattan_distance(sensor, closest_beacon)
      points_beacon_cannot_be_at(sensor, distance, target_y).each do |x_coord|
        beacon_cannot_be_at.add(x_coord) unless beacons.include?({ x: x_coord, y: target_y })
      end
    end

    beacon_cannot_be_at.size
  end

  private

  def manhattan_distance(a, b)
    (a[:x] - b[:x]).abs + (a[:y] - b[:y]).abs
  end

  def points_beacon_cannot_be_at(sensor, manhattan_distance, target_y)
    debug_puts "evaluating m_d=#{manhattan_distance}, t_y=#{target_y}", indent = 1
    beacon_cannot_be_at = Set.new
    if target_y > sensor[:y] && manhattan_distance >= (target_y - sensor[:y])
      debug_puts 'possible to reach target_y above', indent = 2
      # sensor is below, possible to reach target elevation above
      y_spend = target_y - sensor[:y]
      [*0..(manhattan_distance - y_spend)].each do |x|
        debug_puts "adding pos and neg for x=#{x}", indent = 3
        beacon_cannot_be_at.add(sensor[:x] + x)
        beacon_cannot_be_at.add(sensor[:x] + -x)
      end
    end

    if target_y < sensor[:y] && manhattan_distance >= (sensor[:y] - target_y)
      debug_puts 'possible to reach target_y below', indent = 2
      y_spend = sensor[:y] - target_y
      debug_puts "y_spend=#{y_spend}", indent = 2

      [*0..(manhattan_distance - y_spend)].each do |x|
        debug_puts "adding pos and neg for x=#{x}", indent = 3
        beacon_cannot_be_at.add(sensor[:x] + x)
        beacon_cannot_be_at.add(sensor[:x] + -x)
      end
    end

    if target_y == sensor[:y]
      debug_puts 'sensor at target_y', indent = 2

      [*0..manhattan_distance].each do |x|
        beacon_cannot_be_at.add(sensor[:x] + x)
        beacon_cannot_be_at.add(sensor[:x] + -x)
      end
    end

    beacon_cannot_be_at
  end
end

if __FILE__ == $PROGRAM_NAME
  DEBUG_PUTS_ENABLED = false
  parsed = Parser.parse('data/day_15.txt')
  # pp Solution.solution(state: parsed, target_y: 2000000) # 4876693
end
