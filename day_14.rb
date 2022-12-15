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
    y_of_lowest_rock = rocks.map { |point| point[:y] }.max

    {
      start: start,
      y_of_lowest_rock: y_of_lowest_rock,
      rocks: rocks,
      resting_sand: Set.new,
      part_two_floor: part_two_floor(y_of_lowest_rock, rocks)
    }
  end

  private

  def part_two_floor(y_of_lowest_rock, rocks)
    min_x, max_x = rocks.map { |point| point[:x] }.minmax

    # HACK: for infinite floor, use large x values
    [*(min_x - 1000)..(max_x + 1000)].map { |x| { x: x, y: y_of_lowest_rock + 2 } }
                                     .to_set
  end

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

  def solution(state, use_floor:)
    loop do
      resting_point = pour_unit_of_sand!(state, use_floor)
      break if reached_void_or_floor?(resting_point, state, use_floor)
    end

    state[:resting_sand].count
  end

  private

  def reached_void_or_floor?(sand, state, use_floor)
    if use_floor
      sand == state[:start] && can_come_to_rest_without_floor?(sand, state)
    else
      falling_into_the_endless_void?(sand, state)
    end
  end

  def pour_unit_of_sand!(state, use_floor)
    sand = state[:start].dup

    loop do
      if can_come_to_rest?(sand, state, use_floor)
        state[:resting_sand].add(sand)
        return sand
      elsif falling_into_the_endless_void?(sand, state)
        return sand
      elsif empty?(down(sand), state)
        sand = down(sand)
      elsif empty?(down_left(sand), state)
        sand = down_left(sand)
      elsif empty?(down_right(sand), state)
        sand = down_right(sand)
      else
        raise 'unknown condition'
      end
    end
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

  def can_come_to_rest?(point, state, use_floor)
    if use_floor
      can_come_to_rest_with_floor?(point, state)
    else
      can_come_to_rest_without_floor?(point, state)
    end
  end

  def can_come_to_rest_with_floor?(point, state)
    [down(point), down_left(point), down_right(point)].all? do |next_point|
      state[:rocks].include?(next_point) ||
        state[:resting_sand].include?(next_point) ||
        state[:part_two_floor].include?(next_point)
    end
  end

  def can_come_to_rest_without_floor?(point, state)
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
  filepath = 'data/day_14.txt'
  state = Parser.parse(filepath)
  pp Solution.solution(state, use_floor: false)

  state = Parser.parse(filepath)
  pp Solution.solution(state, use_floor: true)
end
