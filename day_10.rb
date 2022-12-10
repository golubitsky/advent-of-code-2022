# frozen_string_literal: true

module Parser
  extend self

  def parse_as_single_cycle_instructions(filepath)
    # Cycles are counted with one-indexing. Add an extra noop at the beginning
    # to allow array indexing to be used without conversion to one-indexing.
    [{ instruction: 'noop' }] +
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
    instructions.each_with_index do |instruction, cycle_index|
      if cycle_of_interest?(cycle_index)
        signal_strength = register_value * cycle_index
        signal_strengths << signal_strength
      end

      register_value += instruction[:amount] if instruction[:instruction] == 'addx'
    end

    signal_strengths.sum
  end

  private

  def cycle_of_interest?(cycle_index)
    cycle_index % 40 == 20
  end
end

if __FILE__ == $PROGRAM_NAME
  instructions = Parser.parse_as_single_cycle_instructions('data/day_10.txt')

  pp Solution.solution(instructions, register_value: 1)
end
