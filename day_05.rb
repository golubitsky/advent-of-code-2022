module Parser
  extend self

  def parsed(input_filepath)
    raw_stacks, raw_moves = File.read(input_filepath).split("\n\n")

    {
      stacks: stacks(raw_stacks),
      moves: moves(raw_moves)
    }
  end

  private

  def stacks(raw_stacks)
    # first line in the raw stacks is the top of the stack
    # instead, let's stack bottom-up, so reverse everything first
    reversed = raw_stacks.split("\n").reverse
    header = reversed.first
    stacks = reversed.drop(1)

    zero_indexed_stack_indexes = header.chars.map
                                       .with_index { |char, index| [char, index] }
                                       .reject { |key, _| key == ' ' }
                                       .to_h
                                       .values

    zero_indexed_stack_indexes.map do |index|
      stacks.map { |stack| stack[index] }.reject { |item| item == ' ' }
    end
  end

  def moves(raw_moves)
    raw_moves.split("\n")
             .map { |line| line.scan(/\d+/).map(&:to_i) }
             .map do |move|
      {
        n_items: move[0],
        from: zero_indexed(move[1]),
        to: zero_indexed(move[2])
      }
    end
  end

  def zero_indexed(item)
    item - 1
  end
end

module CrateMover9000
  extend self

  def apply_moves_to_stacks!(stacks:, moves:)
    moves.each do |move|
      move[:n_items].times do
        from = stacks[move[:from]]
        to = stacks[move[:to]]

        to.push(from.pop)
      end
    end

    stacks
  end
end

module CrateMover9001
  extend self

  def apply_moves_to_stacks!(stacks:, moves:)
    moves.each do |move|
      from = stacks[move[:from]]
      to = stacks[move[:to]]
      n = move[:n_items]

      to.push(*from.pop(n))
    end

    stacks
  end
end

def items_on_top_of_each_stack(stacks)
  stacks.map(&:last).join
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_05.txt'

  parsed = Parser.parsed(input_filepath)
  puts items_on_top_of_each_stack(
    CrateMover9000.apply_moves_to_stacks!(stacks: parsed[:stacks], moves: parsed[:moves])
  )

  parsed = Parser.parsed(input_filepath)
  puts items_on_top_of_each_stack(
    CrateMover9001.apply_moves_to_stacks!(stacks: parsed[:stacks], moves: parsed[:moves])
  )
end
