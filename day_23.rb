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

module Parser
  extend self

  def parse(filepath)
    unparsed = File.read(filepath)

    {
      grove: grove(unparsed),
      moves: moves,
      vector_by_move: vector_by_move
    }
  end

  def grove(unparsed)
    # reverse so that standard Cartesian coordinates can be used
    reversed = unparsed.split("\n").reverse

    reversed.each_with_object(Set.new).with_index do |(line, grove), y|
      line.chars.each_with_index do |char, x|
        next unless char == '#'

        grove.add(Vector[x, y])
      end
    end
  end

  def vector_by_move
    {
      N: [0, 1],
      NE: [1, 1],
      E: [1, 0],
      SE: [1, -1],
      S: [0, -1],
      SW: [-1, -1],
      W: [-1, 0],
      NW: [-1, 1]
    }.transform_values { |x_y| Vector[*x_y] }
  end

  def moves
    [
      {
        checks: %i[N NE NW],
        move_to: :N
      }, {
        checks: %i[S SE SW],
        move_to: :S
      }, {
        checks: %i[W NW SW],
        move_to: :W
      }, {
        checks: %i[E NE SE],
        move_to: :E
      }
    ]
  end
end

module Solution
  extend self

  def solution(grove:, moves:, vector_by_move:)
    round = 1
    loop do
      debug_puts "Round #{round}"
      debug_puts "\ngrove:"
      draw(grove) if ENABLE_DEBUG_LOGS
      proposed_moves = elves_by_proposed_moves(grove, moves, vector_by_move)

      break if proposed_moves.empty?
      break if relative_elf_position_will_not_change?(grove, proposed_moves)

      debug_puts "grove:"
      debug_puts grove
      debug_puts "proposed moves:"
      debug_puts proposed_moves
      proposed_moves.each do |move, elves|
        # Simultaneously, each Elf moves to their proposed destination tile
        # if they were the only Elf to propose moving to that position.
        # If two or more Elves propose moving to the same position, none of those Elves move.
        next unless elves.count == 1

        grove.delete(elves.first)
        grove.add(move)
      end
      moves = moves.rotate

      debug_puts ''
      
      round += 1
    end

    [count_empty_tiles_between_elves(grove), round]
  end

  private

  def relative_elf_position_will_not_change?(grove, proposed_moves)
    unique_moves_proposed_by_exactly_one_elf =
      proposed_moves.map{|k, v| v.count == 1 && v.first - k}.uniq
    
    unique_moves_proposed_by_exactly_one_elf.size == 1 &&
    proposed_moves.size == grove.size
  end

  def elves_by_proposed_moves(grove, moves_to_consider, vector_by_move)
    grove.each_with_object({}) do |elf, proposed|
      next if no_elves_in_sight?(grove, elf, vector_by_move)

      moves_to_consider.each do |checks:, move_to:|
        next unless adjacent_cells_open?(grove, elf, checks, vector_by_move)

        pos_to_move_to = elf + vector_by_move[move_to]
        proposed[pos_to_move_to] ||= []
        proposed[pos_to_move_to] << elf
        break # max one proposed move per elf
      end
    end
  end

  def no_elves_in_sight?(grove, elf, vector_by_move)
    adjacent_cells_open?(grove, elf, vector_by_move.keys, vector_by_move)
  end

  def adjacent_cells_open?(grove, elf, checks, vector_by_move)
    checks.map { |check| elf + vector_by_move[check] }
          .none? { |adjacent_pos| grove.include?(adjacent_pos) }
  end

  def count_empty_tiles_between_elves(grove)
    min_x, max_x = minmax_x(grove)
    min_y, max_y = minmax_y(grove)

    empty_count = 0

    (min_x..max_x).each do |x|
      (min_y..max_y).each do |y|
        empty_count += 1 unless grove.include?(Vector[x, y])
      end
    end

    empty_count
  end

  def draw(grove)
    min_x, max_x = minmax_x(grove)
    min_y, max_y = minmax_y(grove)

    lines = []

    (min_y..max_y).each do |y|
      line = (min_x..max_x).map { |x| grove.include?(Vector[x, y]) ? '#' : '.' }
      line << ' '
      line << y.to_s
      lines << line.join
    end
    debug_puts lines.reverse
    debug_puts x_legend_for_drawing(grove)
  end

  def x_legend_for_drawing(grove)
    min_x, max_x = minmax_x(grove)
    "#{[*(min_x..max_x)].take(10).map.with_index { |x, i| x == 0 ? '0' : ' ' }.join}\n\n"
  end

  def minmax_x(grove)
    grove.map { |coord| coord[0] }.minmax
  end

  def minmax_y(grove)
    grove.map { |coord| coord[1] }.minmax
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_23.txt')
  pp Solution.solution(**parsed)
end
