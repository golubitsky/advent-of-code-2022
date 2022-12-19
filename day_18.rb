# frozen_string_literal: true

require 'set'

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map { |line| line.scan(/\d+/).map(&:to_i) }
  end
end

module Solution
  extend self

  def part_one(input)
    all_cubes = input.to_set

    input.sum do |(x, y, z)|
      count_exposed_surface_area(x, y, z, all_cubes)
    end
  end

  def part_two(cubes, pockets)
    all_cubes = cubes.to_set
    all_pockets = pockets.to_set

    surface_area = cubes.sum do |(x, y, z)|
      adjacent_cubes(x, y, z).count do |cube|
        !all_cubes.include?(cube) && !all_pockets.include?(cube)
      end
    end
  end

  def part_two_precompute_pockets(input, path_to_write_pockets)
    all_cubes = input.to_set

    p x_limits = input.map { |(x, _y, _z)| x }.minmax
    p y_limits = input.map { |(_x, y, _z)| y }.minmax
    p z_limits = input.map { |(_x, _y, z)| z }.minmax
    pockets = Set.new
    (x_limits.first..x_limits.last).each do |x|
      p "checking x=#{x}"
      (y_limits.first..y_limits.last).each do |y|
        (z_limits.first..z_limits.last).each do |z|
          cur_cube = [x, y, z]
          next if all_cubes.include?(cur_cube)

          # TODO: this only finds a pocket of one cube; so the surface_area ends
          # up too high. Need to recursively look for larger pockets...
          path = bfs(cur_cube, all_cubes, x_limits, y_limits, z_limits, pockets)
          next unless path

          p 'discovered pocket'
          open(path_to_write_pockets, 'a') do |f|
            path.each { |cube| f.puts cube.join(',') }
          end
        end
      end
    end
  end

  private

  def bfs(start_cube, all_cubes, x_limits, y_limits, z_limits, pockets)
    q = []
    explored = Set.new
    parents = {}

    # only start searching if it's not a cube
    return false if all_cubes.include?(start_cube)
    # already counted these
    return false if pockets.include?(start_cube)

    explored.add(start_cube)

    q.push(start_cube)

    while q.any?
      cube = q.shift
      x, y, z = cube

      # if can get to edge from a non-cube, not in a pocket
      return false if (x < x_limits[0] || x > x_limits[1]) &&
                      (y < y_limits[0] || y > y_limits[1]) &&
                      (z < z_limits[0] || z > z_limits[1])

      adjacent_cubes(x, y, z).each do |adj_cube|
        next if all_cubes.include?(adj_cube)
        next if explored.include?(adj_cube)

        explored.add(adj_cube)
        parents[adj_cube] = cube
        q.push(adj_cube)

        return trace_path_back(from: adj_cube, to: start_cube, parents: parents) if pockets.include?(adj_cube)
      end
    end

    trace_path_back(from: cube, to: start_cube, parents: parents)
  end

  def trace_path_back(from:, to:, parents:)
    cur = from
    path = []
    while cur != to
      cur = parents[cur]
      path << cur
    end
    path
  end

  def count_exposed_surface_area(x, y, z, all_cubes)
    adjacent_cubes(x, y, z).count { |cube| !all_cubes.include?(cube) }
  end

  def adjacent_cubes(x, y, z)
    [
      [x + 1, y, z],
      [x - 1, y, z],
      [x, y + 1, z],
      [x, y - 1, z],
      [x, y, z + 1],
      [x, y, z - 1]
    ]
  end
end

if __FILE__ == $PROGRAM_NAME
  cubes = Parser.parse('data/day_18.txt')
  pp Solution.part_one(cubes)
  pp Solution.part_two_precompute_pockets(cubes, 'data/day_18_pockets_sample.txt')

  pockets = Parser.parse('data/day_18_pockets.txt').uniq
  pp Solution.part_two(cubes, pockets)
end
