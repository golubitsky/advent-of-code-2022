module RucksackParser
  extend self

  def rucksacks(input_filepath)
    File.readlines(input_filepath)
        .map(&:strip)
        .map { |row| rucksack(row) }
  end

  private

  def rucksack(row)
    midpoint_index = row.size / 2
    first_half = row[0...midpoint_index].chars
    second_half = row[midpoint_index..-1].chars

    {
      compartment: first_half,
      other_compartment: second_half
    }
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

  def sum_of_priorities(rucksacks)
    rucksacks.map { |rucksack| priority(rucksack) }
             .sum
  end

  private

  def priority(rucksack)
    PRIORITY_BY_ITEM[item_that_appears_in_both_compartments(rucksack)]
  end

  def item_that_appears_in_both_compartments(rucksack)
    intersection(rucksack[:compartment], rucksack[:other_compartment]).first
  end

  def intersection(array, other_array)
    array & other_array
  end
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_03.txt'
  rucksacks = RucksackParser.rucksacks(input_filepath)
  pp SumOfPriorities.sum_of_priorities(rucksacks)
end
