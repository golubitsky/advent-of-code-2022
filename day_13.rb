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
      indexes_in_right_order << index + 1 if compare_lists(left, right) == -1
    end

    indexes_in_right_order.sum
  end

  def decoder_key_from_sorted_packets(packets)
    divider_packets = [
      [[2]],
      [[6]]
    ]

    sorted =
      (packets + divider_packets).sort { |a, b| compare_lists(a, b) }

    divider_packets.map { |divider| sorted.index(divider) + 1 }
                   .reduce(:*)
  end

  private

  def compare_lists(a, b)
    (0...[a.size, b.size].max).each do |i|
      left = a[i]
      right = b[i]

      sorted = if integers?(left, right)
                 left <=> right
               elsif lists?(left, right)
                 compare_lists(left, right)
               elsif integer_and_list?(left, right)
                 compare_lists([left], right)
               elsif list_and_integer?(left, right)
                 compare_lists(left, [right])
               elsif right
                 -1
               elsif left
                 1
               end

      return sorted unless sorted.zero?
    end

    0
  end

  def integers?(a, b)
    a.is_a?(Integer) && b.is_a?(Integer)
  end

  def lists?(a, b)
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
