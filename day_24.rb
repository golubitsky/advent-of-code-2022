# frozen_string_literal: true

require 'matrix'
require 'set'

ENABLE_DEBUG_LOGS = false
def debug_print(string)
  print string if ENABLE_DEBUG_LOGS
end

def debug_puts(string)
  puts string if ENABLE_DEBUG_LOGS
end

def debug_p(string)
  p string if ENABLE_DEBUG_LOGS
end

module Constants
  DIRECTION_BY_CHAR = {
    '<' => :left,
    '>' => :right,
    'v' => :down,
    '^' => :up
  }.freeze

  CHAR_BY_DIRECTION = DIRECTION_BY_CHAR.invert

  VECTOR_BY_DIRECTION = {
    up: [0, 1],
    right: [1, 0],
    down: [0, -1],
    left: [-1, 0]
  }.transform_values { |x_y| Vector[*x_y] }
end

module Parser
  include Constants
  extend self

  def parse(filepath)
    unparsed = File.read(filepath)

    v_and_w = valley_and_walls(unparsed)

    {

      start_pos: start_pos(unparsed),
      **v_and_w,
      minmax: {
        x: minmax_x(v_and_w[:walls]),
        y: minmax_y(v_and_w[:walls])
      }
    }
  end

  private

  def minmax_x(walls)
    walls.map { |coord| coord[0] }.minmax
  end

  def minmax_y(walls)
    walls.map { |coord| coord[1] }.minmax
  end

  def start_pos(unparsed)
    hardcoded_x = 1
    hardcoded_y = unparsed.split("\n").count - 1

    Vector[hardcoded_x, hardcoded_y]
  end

  def direction_by_char(char)
    {
      '<' => :left,
      '>' => :right,
      'v' => :down,
      '^' => :up
    }.fetch(char)
  end

  def valley_and_walls(unparsed) # rubocop:disable Metrics/AbcSize
    walls = Set.new
    valley = Hash.new { |h, k| h[k] = [] } # TODO: this is duplicated

    # reverse so that standard Cartesian coordinates can be used
    reversed = unparsed.split("\n").reverse

    reversed.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        next if char == '.'

        if DIRECTION_BY_CHAR.keys.include?(char)
          valley[Vector[x, y]] << DIRECTION_BY_CHAR.fetch(char)
        elsif char == '#'
          walls.add(Vector[x, y])
        else
          raise 'unexpected char'
        end
      end
    end

    {
      walls: walls,
      valley: valley
    }
  end
end

module Draw
  include Constants
  extend self

  def draw(valley, walls, minmax, clear: false)
    system('clear') if clear

    min_x, max_x = minmax[:x]
    min_y, max_y = minmax[:y]

    lines = []

    (min_y..max_y).each do |y|
      line = (min_x..max_x).map { |x| char(x, y, valley, walls) }
      line << ' '
      line << y.to_s
      lines << line.join
    end
    puts lines.reverse
  end

  def char(x, y, valley, walls)
    return '#' if walls.include?(Vector[x, y])

    valley_contents = valley[Vector[x, y]]
    return '.' unless valley_contents

    if walls.include?(Vector[x, y])
      '#'
    elsif valley_contents.count == 1
      CHAR_BY_DIRECTION[valley_contents.first]
    elsif valley_contents.count > 1
      valley_contents.count
    else
      '.'
    end
  end
end

module Solution
  include Constants

  extend self

  def solution(start_pos:, valley:, walls:, minmax:)
    valley_cache = {}

    minute = 0
    loop do
      debug_puts "\n minute #{minute}"
      Draw.draw(valley, walls, minmax, clear: true)

      break if minute == 18

      debug_print 'cur valley: '
      debug_p valley

      current_hash = valley_hash(valley)

      debug_print 'cur hash: '

      debug_p current_hash

      valley_cache[current_hash] ||= next_valley(valley, walls, minmax)
      valley = valley_cache[current_hash]

      debug_print 'next valley: '
      debug_p valley

      minute += 1
      # sleep(0.3)
    end
    nil
  end

  def valley_hash(valley)
    sorted = valley.transform_keys(&:to_a).sort_by { |k, _v| k }.to_h
    sorted.keys.map { |x| "#{x[0]}#{x[1]}" }.join +
      sorted.values.map { |bl| bl.map { |v| CHAR_BY_DIRECTION[v] }.join }.join
  end

  private

  def next_valley(valley, walls, minmax)
    # the construction Hash.new { |h, k| h[k] = [] }
    # leads to undesired effects when this hash is a value in another hash...
    # each of the default values ends up appearing somehow, not sure if it's
    # my own bug or not, but avoiding for now.
    next_valley = {}

    valley.each do |pos, blizzards|
      dup_blizzards = blizzards.dup # avoid pass-by-reference issues
      until dup_blizzards.empty?
        blizzard = dup_blizzards.pop
        proposed_pos = pos + VECTOR_BY_DIRECTION[blizzard]
        next_pos = wrapped_pos(proposed_pos, walls, minmax)
        next_valley[next_pos] ||= []
        next_valley[next_pos].push(blizzard)
      end
    end

    next_valley
  end

  def wrapped_pos(pos, walls, minmax) # rubocop:disable Metrics/AbcSize
    return pos unless walls.include?(pos)

    min_x, max_x = minmax[:x]
    min_y, max_y = minmax[:y]

    # assumptions:
    # 1. blizzards never at corners
    # 2. blizzards never at entry/exit cells
    wrapped = if pos[0] == min_x
                [max_x - 1, pos[1]]
              elsif pos[0] == max_x
                [min_x + 1, pos[1]]
              elsif pos[1] == min_y
                [pos[0], max_y - 1]
              elsif pos[1] == max_y
                [pos[0], min_y + 1]
              end

    Vector[*wrapped]
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_24_sample.txt')
  pp Solution.solution(**parsed)
end
