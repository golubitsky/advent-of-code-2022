# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map(&:strip)
        .reject { |line| line == '' }
        .map { |line| eval(line) }
  end
end

module Solution
  extend self

  def sum_of_packets_in_right_order(input)
    indexes_in_right_order = []

    input.each_slice(2).each_with_index do |(left, right), index|
      indexes_in_right_order << index + 1 if lists_in_right_order?(left, right) == -1
    end

    indexes_in_right_order.sum
  end

  def decoder_key_from_sorted_packets(packets)
    divider_packets = [
      [[2]],
      [[6]]
    ]

    sorted =
      (packets + divider_packets).sort { |a, b| lists_in_right_order?(a, b) }

    divider_packets.map { |divider| sorted.index(divider) + 1 }
                   .reduce(:*)
  end

  private

  def sort_integers(a, b)
    return 0 if a == b

    a < b ? -1 : 1
  end

  def lists_in_right_order?(a, b)
    i = 0

    while i < [a.size, b.size].max
      left = a[i]
      right = b[i]

      sorted = if left && right
                 if integer_and_integer?(left, right)
                   sort_integers(left, right)
                 elsif list_and_list?(left, right)
                   lists_in_right_order?(left, right)
                 elsif integer_and_list?(left, right)
                   lists_in_right_order?([left], right)
                 elsif list_and_integer?(left, right)
                   lists_in_right_order?(left, [right])
                 else
                   raise "unknown data #{left} #{right}"
                 end
               elsif right
                 -1
               elsif left
                 1
               end

      return sorted if sorted != 0

      i += 1
    end

    0
  end

  def integer_and_integer?(a, b)
    a.is_a?(Integer) && b.is_a?(Integer)
  end

  def list_and_list?(a, b)
    a.is_a?(Array) && b.is_a?(Array)
  end

  def integer_and_list?(a, b)
    a.is_a?(Integer) && b.is_a?(Array)
  end

  def list_and_integer?(a, b)
    a.is_a?(Array) && b.is_a?(Integer)
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_13.txt')
  pp Solution.sum_of_packets_in_right_order(parsed)
  pp Solution.decoder_key_from_sorted_packets(parsed)
end
