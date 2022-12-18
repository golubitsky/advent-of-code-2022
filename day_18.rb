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

  def part_two(input)
    all_cubes = input.to_set

    surface_area = input.sum do |(x, y, z)|
      count_exposed_surface_area(x, y, z, all_cubes)
    end

    p xs = input.map { |(x, _y, _z)| x }.minmax
    p ys = input.map { |(_x, y, _z)| y }.minmax
    p zs = input.map { |(_x, _y, z)| z }.minmax
    (xs.first..xs.last).each do |x|
      (ys.first..ys.last).each do |y|
        (zs.first..zs.last).each do |z|
          cur_cube = [x, y, z]
          next if all_cubes.include?(cur_cube)

          # TODO: this only finds a pocket of one cube; so the surface_area ends
          # up too high. Need to recursively look for larger pockets...
          surface_area -= 6 if adjacent_cubes(x, y, z).all? { |cube| all_cubes.include?(cube) }
        end
      end
    end

    surface_area
  end

  private

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
  parsed = Parser.parse('data/day_18.txt')
  pp Solution.part_one(parsed)
  pp Solution.part_two(parsed)
end
