# frozen_string_literal: true

require 'set'

def debug_puts(s)
  puts s if DEBUG_ENABLED
end

def debug_p(s)
  p s if DEBUG_ENABLED
end

module Parser
  extend self

  def parse_jet_patterns(filepath)
    jets = File.read(filepath)
               .strip
               .chars
               .map { |char| char == '<' ? :left : :right }

    Enumerator.new do |yielder|
      i = 0
      loop do
        yielder.yield jets[i % jets.length]
        i += 1
      end
    end
  end
end

module Rocks
  X_START = 2
  ROCKS = {
    horizontal: lambda do |y_bottom|
                  [
                    [X_START, y_bottom],
                    [X_START + 1, y_bottom],
                    [X_START + 2, y_bottom],
                    [X_START + 3, y_bottom]
                  ]
                end,
    cross: lambda do |y_bottom|
             [
               [X_START + 1, y_bottom],
               [X_START,  y_bottom + 1],
               [X_START + 1, y_bottom + 1],
               [X_START + 2, y_bottom + 1],
               [X_START + 1, y_bottom + 2]
             ]
           end,
    reverse_l: lambda do |y_bottom|
                 [
                   [X_START, y_bottom],
                   [X_START + 1, y_bottom],
                   [X_START + 2, y_bottom],
                   [X_START + 2, y_bottom + 1],
                   [X_START + 2, y_bottom + 2]
                 ]
               end,
    vertical: lambda do |y_bottom|
                [
                  [X_START, y_bottom],
                  [X_START, y_bottom  + 1],
                  [X_START, y_bottom  + 2],
                  [X_START, y_bottom  + 3]
                ]
              end,
    square: lambda do |y_bottom|
              [
                [X_START, y_bottom],
                [X_START + 1, y_bottom],
                [X_START, y_bottom + 1],
                [X_START + 1, y_bottom + 1]
              ]
            end
  }
  ROCK_ORDER = ROCKS.keys
  def rock_generator(i)
    ROCKS[ROCK_ORDER[i % ROCKS.size]]
  end
end

module Solution
  LEFT_BOUNDARY = 0
  RIGHT_BOUNDARY = 6
  BOTTOM_BOUNDARY = 0

  include Rocks
  extend self

  def solution(jet_pattern, n_rocks:)
    stopped_rocks = Set.new
    highest_rock_y = -1
    n_rocks.times do |i|
      p i if i % 10_000 == 0
      y_bottom = highest_rock_y + 4
      rock = rock_generator(i).call(y_bottom)
      until stopped?(rock, stopped_rocks)
        jet = jet_pattern.next

        rock = apply_jet(jet, rock, stopped_rocks)

        down_one = descended_one(rock)
        if down_one_ok?(down_one, stopped_rocks)
          rock = down_one
        else
          stop_rock(rock, stopped_rocks)
        end
      end

      # highest rock is always last
      highest_rock_y = [rock.last[1], highest_rock_y].max
    end
    # puts drawn(stopped_rocks, highest_y_to_draw: 20)
    highest_rock_y + 1 # convert y-coord from 0- to 1-indexing
  end

  private

  def highest_y(rock)
    rock.map { |(_x, y)| y }.max
  end

  def drawn(stopped_rocks, highest_y_to_draw:)
    output = []

    (0..highest_y_to_draw).each do |y|
      (LEFT_BOUNDARY..RIGHT_BOUNDARY).each do |x|
        output[y] ||= []
        char = stopped_rocks.include?([x, y]) ? '#' : '.'

        output[y] << (char)
      end
    end

    output.reverse.map(&:join)
  end

  def apply_jet(jet, rock, stopped_rocks)
    case jet
    when :left
      left_one = left_one(rock)
      if move_left_ok?(left_one, stopped_rocks)
        left_one
      else
        rock
      end
    when :right
      right_one = right_one(rock)
      if move_right_ok?(right_one, stopped_rocks)
        right_one
      else
        rock
      end
    else
      raise 'unknown jet'
    end
  end

  def move_left_ok?(rock, stopped_rocks)
    rock.none? { |point| point[0] < LEFT_BOUNDARY || stopped_rocks.include?(point) }
  end

  def move_right_ok?(rock, stopped_rocks)
    rock.none? { |point| point[0] > RIGHT_BOUNDARY || stopped_rocks.include?(point) }
  end

  def down_one_ok?(rock, stopped_rocks)
    rock.none? { |point| point[1] < BOTTOM_BOUNDARY || stopped_rocks.include?(point) }
  end

  def left_one(rock)
    rock.map { |(x, y)| [x - 1, y] }
  end

  def right_one(rock)
    rock.map { |(x, y)| [x + 1, y] }
  end

  def descended_one(rock)
    rock.map { |(x, y)| [x, y - 1] }
  end

  def stopped?(rock, stopped_rocks)
    rock.all? { |point| stopped_rocks.include?(point) }
  end

  def stop_rock(rock, stopped_rocks)
    rock.each { |point| stopped_rocks.add(point) }
  end
end

if __FILE__ == $PROGRAM_NAME
  DEBUG_ENABLED = false
  jet_patterns = Parser.parse_jet_patterns('data/day_17.txt')
  pp Solution.solution(jet_patterns, n_rocks: 2022)
end
