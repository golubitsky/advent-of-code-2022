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

      **start_and_goal(unparsed),
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

  def start_and_goal(unparsed)
    lines = unparsed.split("\n")

    {
      start: Vector[1, lines.count - 1],
      goal: Vector[lines.last.length - 2, 0]
    }
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

  def draw(cur_pos, valley, walls, minmax, clear: false)
    system('clear') if clear

    min_x, max_x = minmax[:x]
    min_y, max_y = minmax[:y]

    lines = []

    (min_y..max_y).each do |y|
      line = (min_x..max_x).map { |x| char(x, y, valley, walls, cur_pos) }
      line << ' '
      line << y.to_s
      lines << line.join
    end
    puts lines.reverse
  end

  def char(x, y, valley, walls, cur_pos)
    v = Vector[x, y]
    return 'E' if v == cur_pos
    return '#' if walls.include?(v)

    valley_contents = valley[v]
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

module Solution # rubocop:disable Metrics/ModuleLength
  include Constants

  extend self

  def solution(start:, goal:, valley:, walls:, minmax:)
    bfs(start, goal, valley, walls, minmax)
  end

  private

  def pause
    require 'io/console'
    puts 'press c to continue'
    return if $stdin.getch == 'c'

    exit
  end

  # Algorithm
  #   At each minute
  #     update valley
  #     each adjacent pos
  #       add_to_queue(pos, valley) if unexplored(pos, valley)
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def bfs(start, goal, valley, walls, minmax)
    next_valley_hash_by_current_hash = {} # only for valley-compute performance; not part of BFS
    valley_by_hash = {} # only for valley-compute performance; not part of BFS

    q = Queue.new
    parents = {} # to trace path back to start when at goal
    explored = Set.new

    explored.add(start)

    # current_hash = valley_hash(valley)
    # next_valley_hash_by_current_hash[current_hash] ||= next_valley(valley, walls, minmax)
    # valley = next_valley_hash_by_current_hash[current_hash]

    h = valley_hash(valley)
    valley_by_hash[h] = valley
    start_state = [start, h]
    q.push(start_state)

    until q.empty?
      state = q.shift
      cur_pos, valley_hash = state
      # puts "\nexploring #{state}"

      return trace_path_back(from: state, to: start_state, parents: parents) if cur_pos == goal

      # precompute to make next valley available for future exploration
      unless next_valley_hash_by_current_hash[valley_hash]
        valley = valley_by_hash[valley_hash]
        next_valley = next_valley(valley, walls, minmax)
        next_valley_hash = valley_hash(next_valley)

        valley_by_hash[next_valley_hash] = next_valley
        # p "next of #{valley_hash} computed as #{next_valley_hash}"
        next_valley_hash_by_current_hash[valley_hash] = next_valley_hash
      end

      # advance blizzard
      next_valley_hash = next_valley_hash_by_current_hash[valley_hash]
      next_valley = valley_by_hash[next_valley_hash]
      # puts "next valley #{next_valley}"

      # print "\n"
      # print 'next valley: '
      # pp next_valley
      # Draw.draw(cur_pos, next_valley, walls, minmax, clear: false)
      # print 'cur pos: '
      # p cur_pos
      # print 'adjacents: '
      # pp open_adjacent_positions(next_valley, walls, minmax, cur_pos)
      # pause

      # Draw.draw(cur_pos, next_valley, walls, minmax, clear: false)

      open_adjacent_positions(next_valley, walls, minmax, cur_pos).each do |adj_pos|
        next_state = [adj_pos, next_valley_hash]

        # puts "can go to #{next_state}"

        next if explored.include?(next_state)

        # puts "adding to q"

        explored.add(next_state)
        parents[next_state] = state
        q.push(next_state)
      end
    end
    raise 'no path found'
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def trace_path_back(from:, to:, parents:)
    p 'tracing path'
    step_count = 0
    cur = from
    while cur != to
      cur = parents[cur]
      step_count += 1
    end
    step_count
  end

  def open_adjacent_positions(valley, walls, minmax, pos)
    VECTOR_BY_DIRECTION
      .values.push(Vector[0, 0]) # staying in place is an option
      .map { |v| Vector[*(pos + v)] }
      .reject { |v| walls.include?(v) || (valley.include?(v) && valley[v].any?) }
      .reject { |v| out_of_bounds?(v, minmax) }
  end

  def out_of_bounds?(pos, minmax)
    pos[0] < minmax[:y].first ||
      pos[1] > minmax[:y].last ||
      pos[0] < minmax[:x].first ||
      pos[1] > minmax[:x].last
  end

  def valley_hash(valley)
    sorted = valley.transform_keys(&:to_a).sort_by { |k, _v| k }.to_h
    sorted.map do |(x, y), blizzards|
      "#{x}#{y}#{blizzards.map { |bl| CHAR_BY_DIRECTION[bl] }.join}"
    end.join.to_sym
  end

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
  parsed = Parser.parse('data/day_24.txt')
  pp Solution.solution(**parsed)
end
