# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map(&:to_i)
  end
end

class Day20Number
  attr_reader :value, :original_index
  attr_accessor :current_index

  def initialize(value, original_index)
    @value = value
    @original_index = original_index
    @current_index = original_index
  end

  def inspect
    "oi=#{original_index} ci=#{current_index} v=#{value}"
  end

  def inspect
    value
  end

  def to_i
    value
  end
end

module Solution
  extend self

  def solution(input)
    count = input.count
    original = input.each_with_object({}).with_index do |(n, obj), index|
      obj[index] = Day20Number.new(n, index)
    end

    mixture = original.values

    # p mixture
    expected = [
      [2, 1, -3, 3, -2, 0, 4],
      [1, -3, 2, 3, -2, 0, 4],
      [1, 2, 3, -2, -3, 0, 4],
      [1, 2, -2, -3, 0, 3, 4],
      [1, 2, -3, 0, 3, 4, -2],
      [1, 2, -3, 0, 3, 4, -2],
      [1, 2, -3, 4, 0, 3, -2]
    ]
    original.each do |original_index, number|
      source_index = mixture.index { |n| n.equal?(number) }

      destination_index = if number.value.positive?
                            if source_index + number.value < count
                              source_index + number.value + 1
                            else
                              ((source_index + number.value) % count) + 1
                            end
                          elsif number.value.zero?
                            next
                          elsif number.value.negative?
                            source_index + number.value
                          end

      destination_index += count if destination_index.negative?
      # puts "n: #{number.value} s: #{source_index} d: #{destination_index}"

      destination_index -= 1 if source_index < destination_index
      destination_index = -1 if destination_index.zero?

      translation = number.value
      cur_index = source_index

      puts "n: #{number.value} from #{source_index}"

      if translation.positive?
        i = 0
        while i < translation
          idx = i + cur_index
          mixture[idx % count], mixture[idx % count + 1] = mixture[idx % count + 1], mixture[idx % count]
          i += 1
        end
      elsif translation.negative?
        i = 0
        (-translation - 1).times do
          idx = (cur_index - i)
          below = idx - 1
          mixture[idx], mixture[below] = mixture[below], mixture[idx]
          i += 1
        end
      else
        raise 'unexpected condition'
      end
      # mixture.insert(destination_index, mixture.delete_at(source_index))

      puts "exp #{expected[original_index]}"
      print 'act '
      p mixture
    end

    ints = mixture.map(&:to_i)
    index_of_zero = ints.index(0)
    [1000, 2000, 3000].sum { |n| mixture[(index_of_zero + n) % count].to_i }
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_20_sample.txt')
  pp Solution.solution(parsed)
end
