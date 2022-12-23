# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    maze, path = File.read(filepath).split("\n\n")

    metadata = metadata(maze)
    parsed_maze = parsed_maze(maze)

    {
      # highest/first line on screen will be y=0
      # lowest/last line on screen will be y=maze.size - 1
      **metadata,
      maze: parsed_maze,
      path: parsed_path(path),
      cube_maze: cube_sides(parsed_maze, metadata[:max_x], metadata[:max_y], filepath)
    }
  end

  private

  def cube_sides(parsed_maze, max_x, max_y, filepath)
    if filepath.include?('sample')
      cube_size = 4

      side_by_pos = sample_cube_sides(parsed_maze, max_x, max_y, cube_size)
      parsed_maze.each_with_object({}) do |(pos, value), obj|
        obj[pos] = {
          cell: value,
          # TODO: WIP edge? is a misnomer; it's supposed to precompute
          # - the destination pos
          # - the destination direction
          # for every edge cell. That should make traversal simple.
          up: edge?(pos, side_by_pos, cube_size) ? 'edge' : :up,
          right: '',
          down: '',
          left: ''
        }
      end
    else
      full_cube_sides(parsed_maze, max_x, max_y, filepath)
    end
  end

  def edge?(pos, side_by_pos, cube_size)
    x, y = pos
    cube_side_x = x / cube_size
    cube_side_y = y / cube_size
    cube_pos_x = x % cube_size
    cube_pos_y = y % cube_size
    cube_pos = [x % cube_size, y % cube_size]
    {
      [2, 0] => 1,
      [0, 1] => 2,
      [1, 1] => 3,
      [2, 1] => 4,
      [2, 2] => 5,
      [3, 2] => 6
    }
    p "#{side_by_pos[pos]} #{cube_pos}"
  end

  def full_cube_sides(_parsed_maze, _max_x, _max_y, _cube_size)
    cube_size = 50
  end

  def sample_cube_sides(parsed_maze, max_x, max_y, cube_size)
    sides = {}
    (0..max_y).each do |y|
      (0..max_x).each do |x|
        next unless parsed_maze[[x, y]]

        cube_side_x = x / cube_size
        cube_side_y = y / cube_size
        sides[[x, y]] = {
          [2, 0] => 1,
          [0, 1] => 2,
          [1, 1] => 3,
          [2, 1] => 4,
          [2, 2] => 5,
          [3, 2] => 6
        }.fetch([cube_side_x, cube_side_y])
      end
    end
    sides
  end

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
  parsed = Parser.parse('data/day_22_sample.txt')
  pp parsed[:cube_maze]
  # pp Solution.solution(parsed)
end
