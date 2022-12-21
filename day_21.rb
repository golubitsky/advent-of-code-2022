# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .to_h do |line|
      monkey, operation = line.split(':')
      [monkey.to_sym, parse_monkey(operation)]
    end
  end

  def parse_monkey(line)
    fragments = line.split

    if fragments.count == 1
      { result: fragments.first.to_i }
    else
      {
        a: fragments.first.to_sym,
        operand: fragments[1].to_sym,
        b: fragments.last.to_sym
      }
    end
  end
end

module Solution
  extend self

  def part_one(monkeys)
    until monkeys[:root][:result]
      monkeys.each do |name, operation|
        next if operation[:result]

        a = monkeys[operation[:a]][:result]
        b = monkeys[operation[:b]][:result]

        next unless a && b

        monkeys[name][:result] = a.send(operation[:operand], b)
      end
    end
    monkeys[:root][:result]
  end

  def part_two(monkeys, humn_value:)
    monkeys[:humn][:result] = humn_value

    until monkeys[:root][:result]
      monkeys.each do |name, operation|
        next if operation[:result]

        a = monkeys[operation[:a]][:result]
        b = monkeys[operation[:b]][:result]

        next unless a && b

        monkeys[name][:result] = a.send(operation[:operand], b)
      end
    end
    root = monkeys[:root]
    # require 'pry'; binding.pry
    # puts monkeys[root[:b]][:result]
    [
      monkeys[root[:a]][:result],
      monkeys[root[:b]][:result]
    ]
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_21.txt')
  pp Solution.part_one(parsed)

  i = 3_665_520_865_940
  parsed = Parser.parse('data/day_21.txt')
  result = Solution.part_two(parsed, humn_value: i)
  p result.map(&:to_s).map(&:length)
  pp "#{result} diff=#{result.last - result.first} i=#{i}"
end
