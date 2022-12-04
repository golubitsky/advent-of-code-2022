module RucksackParser
  extend self

  def part_one_rucksacks(input_filepath)
    File.readlines(input_filepath)
        .map(&:strip)
        .map { |row| part_one_rucksack(row) }
  end

  def part_two_rucksacks(input_filepath)
    File.readlines(input_filepath)
        .map(&:strip)
        .map(&:chars)
        .each_slice(3)
        .to_a
  end

  private

  def part_one_rucksack(row)
    midpoint_index = row.size / 2
    first_half = row[0...midpoint_index].chars
    second_half = row[midpoint_index..-1].chars

    [first_half, second_half]
  end
end

module SumOfPriorities
  POSSIBLE_ITEMS = [*'a'..'z', *'A'..'Z'].freeze
  PRIORITY_BY_ITEM = Hash[
    POSSIBLE_ITEMS.map.with_index do |letter, index|
      [letter, index + 1]
    end
  ].freeze

  private_constant :POSSIBLE_ITEMS, :PRIORITY_BY_ITEM

  extend self

  # Accepts an array of either rucksack compartments or of multiple rucksacks
  def sum_of_priorities(collection_of_compartments)
    collection_of_compartments.map { |compartments| priority(compartments) }
                              .sum
  end

  private

  def priority(compartments)
    PRIORITY_BY_ITEM[common_item(compartments)]
  end

  def common_item(compartments)
    intersection(*compartments).first
  end

  def intersection(*arrays)
    arrays.inject { |intersection, array| intersection & array }
  end
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_03.txt'
  pp SumOfPriorities.sum_of_priorities(
    RucksackParser.part_one_rucksacks(input_filepath)
  )

  pp SumOfPriorities.sum_of_priorities(
    RucksackParser.part_two_rucksacks(input_filepath)
  )
end
