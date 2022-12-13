# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath); end
end

module Solution
  extend self

  def solution(input); end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_DAY_NUMBER_sample.txt')
  pp Solution.solution(parsed)
end
