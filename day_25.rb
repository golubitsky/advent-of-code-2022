# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath).map(&:strip)
  end
end

module Solution
  extend self

  ACTUAL_CHAR_BY_SNAFU_CHAR = {
    '2' => 2,
    '1' => 1,
    '0' => 0,
    '-' => -1,
    '=' => -2
  }.freeze

  SNAFU_CHARS = ACTUAL_CHAR_BY_SNAFU_CHAR.keys.freeze

  def solution(input)
    goal = input.sum { |snafu_number| number(snafu_number) }

    synthesize_snafu(goal)
  end

  private

  def number(snafu_number)
    converted = snafu_number.reverse.chars.map.with_index do |char, index|
      { digit: ACTUAL_CHAR_BY_SNAFU_CHAR[char], value: 5**index }
    end

    converted.map { |n| n[:digit] * n[:value] }.sum
  end

  def synthesize_snafu(n)
    p n
    p number('2----0=--1122=0=0021')
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_25.txt')
  pp Solution.solution(parsed)
end
