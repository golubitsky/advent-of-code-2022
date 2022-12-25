# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
  end
end

module Solution
  extend self

  def solution(input)
    input
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_25_sample.txt')
  pp Solution.solution(parsed)
end
