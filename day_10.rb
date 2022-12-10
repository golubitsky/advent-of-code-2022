# frozen_string_literal: true

module Parser
  extend self

  def parse_as_single_cycle_instructions(filepath)
    File.readlines(filepath)
        .map(&:strip)
        .flat_map do |line|
          instruction = line.split.first
          case instruction
          when 'noop'
            { instruction: 'noop' }
          when 'addx'
            [
              { instruction: 'noop' }, # each addx takes two cycles to implement
              { instruction: 'addx', amount: line.split.last.to_i }
            ]
          end
        end
  end
end

module Solution
  extend self

  def solution(instructions, register_value: 1)
    signal_strengths = []
    crt_rows = []

    instructions.each_with_index do |instruction, index|
      draw_pixel_based_on_sprite_position!(crt_rows, index, register_value)

      cycle_index = index + 1 # cycles are 1-indexed, not 0-indexed
      if cycle_of_interest?(cycle_index)
        signal_strength = register_value * cycle_index
        signal_strengths << signal_strength
      end

      register_value += instruction[:amount] if instruction[:instruction] == 'addx'
    end

    [signal_strengths.sum, crt_rows.map(&:join)]
  end

  private

  def cycle_of_interest?(cycle_index)
    cycle_index % 40 == 20
  end

  def draw_pixel_based_on_sprite_position!(crt_rows, index, register_value)
    crt_row_index = index / 40
    crt_rows[crt_row_index] ||= []
    crt_row = crt_rows[crt_row_index]
    sprite_positions = [register_value - 1, register_value, register_value + 1]
    crt_row << (sprite_positions.include?(index % 40) ? '#' : '.')
  end
end

if __FILE__ == $PROGRAM_NAME
  instructions = Parser.parse_as_single_cycle_instructions('data/day_10.txt')

  puts Solution.solution(instructions, register_value: 1)
end
