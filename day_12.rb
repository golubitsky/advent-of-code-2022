# frozen_string_literal: true

require 'set'

module Parser
  extend self

  def parse(filepath)
    maze = File.readlines(filepath)
               .map(&:strip)

    goal_y = maze.index { |row| row.include? 'E' }
    goal_x = maze[goal_y].index('E')

    start_y = maze.index { |row| row.include? 'S' }
    start_x = maze[start_y].index('S')

    # assign elevations to start and end
    maze[start_y][start_x] = 'a'
    maze[goal_y][goal_x] = 'z'

    original_start_pos = [start_y, start_x]
    {
      start_positions: start_positions(maze, original_start_pos),
      goal_pos: [goal_y, goal_x],
      maze: maze
    }
  end

  def start_positions(maze, original_start_pos)
    start_positions = [original_start_pos]

    maze.each_with_index do |row, y|
      row.chars.each_with_index do |letter, x|
        next if original_start_pos == [y, x] # don't add it again, but keep it first

        start_positions << [y, x] if letter == 'a'
      end
    end

    start_positions
  end
end

module Solution
  extend self

  def solution(maze:, start_positions:, goal_pos:, only_solve_first_starting_pos:)
    start_positions = only_solve_first_starting_pos ? [start_positions.first] : start_positions

    start_positions.map { |start_pos| bfs(maze, start_pos, goal_pos) }
                   .compact # ignore starting positions without solution
                   .min
  end

  private

  def bfs(maze, start_pos, goal_pos)
    q = []
    parents = {} # to trace path back to start when at goal
    explored = Set.new

    explored.add(start_pos)

    q.push(start_pos)

    while q.any?
      cur_pos = q.shift
      return trace_path_back(from: cur_pos, to: start_pos, parents: parents) if cur_pos == goal_pos

      legal_adjacent_positions(maze, cur_pos).each do |adj_pos|
        next if explored.include?(adj_pos)

        explored.add(adj_pos)
        parents[adj_pos] = cur_pos
        q.push(adj_pos)
      end
    end
  end

  def potential_positions(maze, cur_pos)
    moves = []
    y, x = cur_pos
    moves << [y - 1, x] if y.positive? # look up
    moves << [y, x - 1] if x.positive? # look left
    moves << [y + 1, x] if y < maze.length - 1 # look down
    moves << [y, x + 1] if x < maze.first.length - 1 # look right
    moves
  end

  def legal_adjacent_positions(maze, cur_pos)
    potential_positions(maze, cur_pos).select do |potential_pos|
      highest_can_go_from_here = letter_ord(cur_pos, maze) + 1
      adjacent_height = letter_ord(potential_pos, maze)

      highest_can_go_from_here >= adjacent_height
    end
  end

  def letter_ord(pos, maze)
    y, x = pos
    maze[y][x].ord
  end

  def trace_path_back(from:, to:, parents:)
    step_count = 0
    cur = from
    while cur != to
      cur = parents[cur]
      step_count += 1
    end
    step_count
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_12.txt')
  pp Solution.solution(**parsed, only_solve_first_starting_pos: true)
  pp Solution.solution(**parsed, only_solve_first_starting_pos: false)
end
