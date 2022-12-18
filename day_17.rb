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
    n_rocks.times do |i|
      p i if i % 10000 == 0
      y_bottom = highest_rock_y(stopped_rocks) + 4
      rock = rock_generator(i).call(y_bottom)
      debug_p rock
      until stopped?(rock, stopped_rocks)
        jet = jet_pattern.next
        rock = apply_jet(jet, rock, stopped_rocks)

        if can_descend?(rock, stopped_rocks)
          debug_puts 'descend'
          rock = descended_one(rock)
        else
          debug_puts 'stop'
          stop_rock(rock, stopped_rocks)
        end
      end
    end
    # puts drawn(stopped_rocks, highest_y_to_draw: 20)
    highest_rock_y(stopped_rocks) + 1 # convert y-coord from 0- to 1-indexing
  end

  private

  def highest_rock_y(stopped_rocks)
    stopped_rocks.empty? ? -1 : stopped_rocks.map { |(_x, y)| y }.max
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
      if can_jet_left?(rock, stopped_rocks)
        debug_puts 'jet left'
        left_one(rock)
      else
        debug_puts 'cannot jet left'
        rock
      end
    when :right
      if can_jet_right?(rock, stopped_rocks)
        debug_puts 'jet right'
        right_one(rock)
      else
        debug_puts 'cannot jet right'
        rock
      end
    else
      raise 'unknown jet'
    end
  end

  def can_jet_left?(rock, stopped_rocks)
    moved = left_one(rock)

    moved.none? { |point| stopped_rocks.include?(point) } &&
      moved.none? { |(x, _y)| x < LEFT_BOUNDARY }
  end

  def can_jet_right?(rock, stopped_rocks)
    moved = right_one(rock)

    moved.none? { |point| stopped_rocks.include?(point) } &&
      moved.none? { |(x, _y)| x > RIGHT_BOUNDARY }
  end

  def can_descend?(rock, stopped_rocks)
    moved = descended_one(rock)

    moved.none? { |point| stopped_rocks.include?(point) } &&
      moved.none? { |(_x, y)| y < BOTTOM_BOUNDARY }
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
