# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.read(filepath)
        .split("\n\n")
        .map { |monkey_spec| monkey_spec.split("\n") }
        .map(&method(:monkey))
  end

  private

  def monkey(five_lines)
    starting_items = five_lines[1].scan(/\d+/).map(&:to_i)

    first_operand, operator, second_operand = five_lines[2].split.drop(3)
    operator = operator.to_sym
    operation = { left: operand(first_operand), operator: operator, right: operand(second_operand) }

    test = {
      divisible_by: five_lines[3].scan(/\d+/).first.to_i,
      yes: five_lines[4].scan(/\d+/).first.to_i,
      no: five_lines[5].scan(/\d+/).first.to_i
    }
    m = {
      starting_items: starting_items,
      operation: operation,
      test: test
    }
  end

  def operand(input)
    input == 'old' ? :old : input.to_i
  end
end

module Solution
  extend self

  def solution(monkeys, reduce_worry_levels_during_round:, rounds:)
    monkey_inspection_counts = Hash.new(0)

    rounds.times do
      perform_round(monkeys, monkey_inspection_counts, reduce_worry_levels_during_round)
    end

    monkey_inspection_counts.sort_by { |_index, count| -count }
                            .to_h
                            .values
                            .take(2)
                            .reduce(:*)
  end

  private

  def perform_round(monkeys, monkey_inspection_counts, reduce_worry_levels_during_round)
    # I don't get this number theory thing. Cheated and read about it on Reddit.
    product_divisors = monkeys.map { |x| x[:test][:divisible_by] }.reduce(:*)

    monkeys.each_with_index do |monkey, index|
      monkey_inspection_counts[index] += monkey[:starting_items].count

      operation_applied = monkey[:starting_items].map { |item| apply_operation(item, monkey[:operation]) }

      bored = if reduce_worry_levels_during_round
                operation_applied.map { |item| item / 3 }
              else
                (operation_applied.map do |item|
                   item % product_divisors
                 end)
              end

      result_monkeys_indexes = bored.map do |bored_item|
        if (bored_item % monkey.dig(:test, :divisible_by)).zero?
          monkey.dig(:test, :yes)
        else
          monkey.dig(:test, :no)
        end
      end

      monkey[:starting_items] = []
      result_monkeys_indexes.zip(bored).each do |result_monkey_index, item|
        monkeys[result_monkey_index][:starting_items] << item
      end
    end
  end

  def apply_operation(old, operation)
    left = if operation[:left] == :old
             old
           else
             raise 'expected left to be old'
           end

    right = if operation[:right] == :old
              old
            else
              operation[:right]
            end

    left.send(operation[:operator], right)
  end
end

if __FILE__ == $PROGRAM_NAME
  monkeys = Parser.parse('data/day_11.txt')
  pp Solution.solution(monkeys, reduce_worry_levels_during_round: true, rounds: 20)

  monkeys = Parser.parse('data/day_11.txt')
  pp Solution.solution(monkeys, reduce_worry_levels_during_round: false, rounds: 10_000)
end
