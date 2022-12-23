# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    maze, path = File.read(filepath).split("\n\n")

    {
      # highest/first line on screen will be y=0
      # lowest/last line on screen will be y=maze.size - 1
      **metadata(maze),
      maze: parsed_maze(maze),
      path: parsed_path(path)
    }
  end

  private

  def metadata(maze)
    lines = maze.split("\n")
    {
      start_coord: [lines.first.index('.'), 0],
      max_x: lines.map { |line| line.chars.rindex { |x| ['.', '#'].include?(x) } }.max,
      max_y: lines.count - 1
    }
  end

  def parsed_maze(maze)
    maze.split("\n").each_with_object({}).with_index do |(line, obj), y|
      line.chars.each_with_index do |char, x|
        add_char_to_maze!(char: char, maze: obj, coord: [x, y])
      end
    end
  end

  def add_char_to_maze!(char:, maze:, coord:)
    case char
    when ' '
      # not in play
    when '#'
      maze[coord] = :wall
    when '.'
      maze[coord] = :open
    else
      raise 'unexpected maze content'
    end
  end

  def parsed_path(path)
    path.scan(/\d+|\w/).map do |x|
      if %w[L R].include?(x)
        x.to_sym
      elsif x.to_i.to_s == x
        x.to_i
      else
        raise 'unexpected path input'
      end
    end
  end
end

module MazePrinter
  extend self

  def print(state, been_to)
    p been_to
    (0..state[:max_y]).each do |y|
      line = []
      (0..state[:max_x]).each do |x|
        maze_value = state[:maze][[x, y]]

        line << (maze_value.nil? ? ' ' : char(maze_value: maze_value))
      end
      puts line.join
    end
    puts
    nil
  end

  private

  def char(maze_value:)
    case maze_value
    when :open
      '.'
    when :wall
      '#'
    else
      raise "cannot draw #{maze_value}"
    end
  end
end

module Solution
  CLOCKWISE_DIRECTIONS = %i[right down left up].freeze
  extend self

  def solution(state)
    position = state[:start_coord].dup
    direction = CLOCKWISE_DIRECTIONS.first

    been_to = {}
    been_to[position] = direction

    state[:path].each do |step|
      puts "facing #{direction} at #{position}\tprocessing #{step}" if false
      position, direction = implement_step(state, position, direction, step)

      been_to[position] = direction
    end

    password(position, direction)
  end

  def password(position, direction)
    row = position[1] + 1
    col = position[0] + 1

    (1000 * row) + (4 * col) + %i[right down left up].index(direction)
  end

  def implement_step(state, position, direction, step)
    case step
    when :L
      direction = turn_left(current: direction)
    when :R
      direction = turn_right(current: direction)
    when Integer
      position = move(state, position, direction, n_steps: step)
    else
      raise "unknown path step #{step}"
    end

    [position, direction]
  end

  def move(state, position, direction, n_steps:)
    cur_pos = position

    n_steps.times do
      next_pos = pos_one_unit_in_direction(cur_pos, direction)

      return cur_pos if wall?(state[:maze], next_pos)

      if open?(state[:maze], next_pos)
        cur_pos = next_pos
      else
        wrapped_pos = wraparound_in_direction(next_pos, direction, state)

        if wall?(state[:maze], wrapped_pos)
          return cur_pos
        elsif open?(state[:maze], wrapped_pos)
          cur_pos = wrapped_pos
        else
          raise 'unexpected condition'
        end
      end
    end

    cur_pos
  end

  def pos_one_unit_in_direction(position, direction)
    {
      left: [position[0] - 1, position[1]],
      right: [position[0] + 1, position[1]],
      up: [position[0], position[1] - 1],
      down: [position[0], position[1] + 1]
    }[direction]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def wraparound_in_direction(position, direction, state)
    case direction
    when :left
      new_pos = [state[:max_x], position[1]]
      new_pos = [new_pos[0] - 1, new_pos[1]] while out_of_bounds?(state[:maze], new_pos)
    when :right
      new_pos = [0, position[1]]
      new_pos = [new_pos[0] + 1, new_pos[1]] while out_of_bounds?(state[:maze], new_pos)
    when :up
      new_pos = [position[0], state[:max_y]]
      new_pos = [new_pos[0], new_pos[1] - 1] while out_of_bounds?(state[:maze], new_pos)
    when :down
      new_pos = [position[0], 0]
      new_pos = [new_pos[0], new_pos[1] + 1] while out_of_bounds?(state[:maze], new_pos)
    end
    new_pos
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity

  def open?(maze, position)
    maze[position] == :open
  end

  def wall?(maze, position)
    maze[position] == :wall
  end

  def out_of_bounds?(maze, position)
    maze[position].nil?
  end

  def turn_right(current:)
    CLOCKWISE_DIRECTIONS.rotate(1)[CLOCKWISE_DIRECTIONS.index(current)]
  end

  def turn_left(current:)
    CLOCKWISE_DIRECTIONS.rotate(-1)[CLOCKWISE_DIRECTIONS.index(current)]
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_22.txt')
  pp Solution.solution(parsed)
end
