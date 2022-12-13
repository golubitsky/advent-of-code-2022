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

  def sum_of_packet_indexes_of_packets_in_right_order(packets)
    packets.each_slice(2)
           .map.with_index { |(a, b), i| in_right_order?(a, b) ? i + 1 : 0 }
           .sum
  end

  def decoder_key_from_sorted_packets(packets)
    divider_packets = [
      [[2]],
      [[6]]
    ]

    sorted = (packets + divider_packets).sort { |a, b| compare_lists(a, b) }

    divider_packets
      .map { |divider| sorted.index(divider) + 1 }
      .reduce(:*)
  end

  private

  def in_right_order?(a, b)
    compare_lists(a, b) == -1
  end

  def compare_lists(a, b)
    (0...[a.size, b.size].max).each do |i|
      compared = if a[i] && b[i]
                   compare_items!(a[i], b[i])
                 elsif b[i]
                   -1
                 elsif a[i]
                   1
                 end

      return compared unless compared.zero?
    end

    0
  end

  def compare_items!(a, b)
    if integers?(a, b)
      a <=> b
    elsif lists?(a, b)
      compare_lists(a, b)
    elsif integer_and_list?(a, b)
      compare_lists([a], b)
    elsif list_and_integer?(a, b)
      compare_lists(a, [b])
    else
      raise "unexpected data types #{a} #{b}"
    end
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
  pp Solution.sum_of_packet_indexes_of_packets_in_right_order(parsed)
  pp Solution.decoder_key_from_sorted_packets(parsed)
end
