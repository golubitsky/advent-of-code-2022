# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map(&:strip)
        .reject { |line| line == '' }
        .map { |line| eval(line) }
        .each_slice(2)
  end

  def parse_part_two(filepath)
    File.readlines(filepath)
        .map(&:strip)
        .reject { |line| line == '' }
        .map { |line| eval(line) }
  end
end

module Solution
  extend self

  def solution(input)
    indexes_in_right_order = []

    input.each_with_index do |(left, right), index|
      indexes_in_right_order << index + 1 if lists_in_right_order?(left, right) == 1
    end

    indexes_in_right_order.sum
  end

  def sort_with_divider_packets(input)
    divider_packet = [[2]]
    other_divider_packet = [[6]]

    packets = input + [divider_packet, other_divider_packet]

    sorted = packets.sort { |a, b| -lists_in_right_order?(a, b) }

    (sorted.index(divider_packet) + 1) * (sorted.index(other_divider_packet) + 1)
  end

  private

  def lists_in_right_order?(a, b)
    i = 0

    while i < [a.size, b.size].max
      left = a[i]
      right = b[i]

      if left && right
        if integer_and_integer?(left, right)
          if left == right
            i += 1
            next
          end

          return left < right ? 1 : -1
        elsif list_and_list?(left, right)
          inner = lists_in_right_order?(left, right)
          if inner == 0
            i += 1
            next
          else
            return inner
          end

        elsif integer_and_list?(left, right)
          inner = lists_in_right_order?([left], right)
          if inner == 0
            i += 1
            next
          else
            return inner
          end
        elsif list_and_integer?(left, right)
          inner = lists_in_right_order?(left, [right])
          if inner == 0
            i += 1
            next
          else
            return inner
          end
        else
          raise "unknown data #{left} #{right}"
        end
      elsif right
        return 1
      elsif left
        return -1
      else
        raise 'unexpected condition'
      end
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

# If both values are integers, the lower integer should come first.
# If the left integer is lower than the right integer, the inputs are in the right order.
# If the left integer is higher than the right integer, the inputs are not in the right order.
# Otherwise, the inputs are the same integer; continue checking the next part of the input.

# If both values are lists, compare the first value of each list,
# then the second value, and so on. If the left list runs out of items first,
# the inputs are in the right order. If the right list runs out of items first,
# the inputs are not in the right order. If the lists are the same length and
# no comparison makes a decision about the order, continue checking the next part of the input.

# If exactly one value is an integer, convert the integer to a list which contains
# that integer as its only value, then retry the comparison.
# For example, if comparing [0,0,0] and 2, convert the right value to [2]
# (a list containing 2); the result is then found by instead comparing [0,0,0] and [2].

if __FILE__ == $PROGRAM_NAME
  path = 'data/day_13.txt'
  parsed = Parser.parse(path)
  pp Solution.solution(parsed)
  parsed = Parser.parse_part_two(path)
  pp Solution.sort_with_divider_packets(parsed)
end
