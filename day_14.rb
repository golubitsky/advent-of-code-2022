# frozen_string_literal: true

require 'set'

module Parser
  extend self

  def parse(filepath)
    lines = File.readlines(filepath)
                .map { |line| line.scan(/(\d+),(\d+)/) }
                .map { |line| line.map { |(x, y)| { x: x.to_i, y: y.to_i } } }

    start = { x: 500, y: 0 }

    rocks = rocks(lines)

    {
      start: start,
      y_of_lowest_rock: rocks.map { |point| point[:y] }.max,
      rocks: rocks,
      resting_sand: Set.new
    }
  end

  private

  def points_between(point_one, point_two)
    if point_one[:x] == point_two[:x]
      y_one, y_two = [point_one[:y], point_two[:y]].minmax
      (y_one..y_two).map { |intermediate_y| { x: point_one[:x], y: intermediate_y } }
    elsif point_one[:y] == point_two[:y]
      x_one, x_two = [point_one[:x], point_two[:x]].minmax
      (x_one..x_two).map { |intermediate_x| { x: intermediate_x, y: point_one[:y] } }
    else
      raise 'diagonal lines not supported'
    end
  end

  def rocks(lines)
    lines.each_with_object(Set.new) do |points, rocks|
      points.each_with_index do |point, index|
        next_point = points[index + 1]
        break unless next_point # last one has no pair

        points_between(point, next_point)
          .each { |point_on_line| rocks.add(point_on_line) }
      end
    end
  end
end

module Solution
  extend self

  def solution(state)
    loop do
      resting_point = pour_unit_of_sand!(state)
      break if falling_into_the_endless_void?(resting_point, state)
    end

    state[:resting_sand].count
  end

  private

  def pour_unit_of_sand!(state)
    sand = state[:start].dup

    loop do
      if can_come_to_rest?(sand, state)
        state[:resting_sand].add(sand)
        break
      elsif falling_into_the_endless_void?(sand, state)
        break
      elsif empty?(down(sand), state)
        sand = down(sand)
      elsif empty?(down_left(sand), state)
        sand = down_left(sand)
      elsif empty?(down_right(sand), state)
        sand = down_right(sand)
      else
        raise 'hi'
      end
    end
    sand
  end

  def empty?(point, state)
    !(rock?(point, state) || sand?(point, state))
  end

  def rock?(point, state)
    state[:rocks].include?(point)
  end

  def sand?(point, state)
    state[:resting_sand].include?(point)
  end

  def down(point)
    {
      x: point[:x],
      y: point[:y] + 1
    }
  end

  def down_left(point)
    {
      x: point[:x] - 1,
      y: point[:y] + 1
    }
  end

  def down_right(point)
    {
      x: point[:x] + 1,
      y: point[:y] + 1
    }
  end

  def can_come_to_rest?(point, state)
    [down(point), down_left(point), down_right(point)].all? do |next_point|
      state[:rocks].include?(next_point) ||
        state[:resting_sand].include?(next_point)
    end
  end

  def falling_into_the_endless_void?(point, state)
    point[:y] > state[:y_of_lowest_rock]
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_14.txt')
  pp Solution.solution(parsed)
end
