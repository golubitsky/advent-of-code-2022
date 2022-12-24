# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .map { |line| blueprint(line) }
  end

  private

  # Hash robot => [{material:, cost:}]
  def blueprint(line)
    scanned = line.split(/:|\./).drop(1)
                  .map { |x| x.scan(/ore|clay|obsidian|geode|\d+/) }
                  .reject(&:empty?)

    scan_by_robot = scanned.to_h { |x| [x.first, x.drop(1)] }

    scan_by_robot.to_h do |robot, scan|
      [
        robot.to_sym,
        scan.each_slice(2).map do |(cost, material)|
          { material: material, cost: cost }
        end
      ]
    end
  end
end

class Solution

  def initialize
    # this is just for one, but will have to do best out of all blueprints
    @best = 1
  end
  def solution(blueprints)
    n_minutes = 24

    blueprints.each do |blueprint|
      simulate(blueprint, n_minutes)
      exit
    end
  end

  def simulate(blueprint)
    counts = {
      ore: 1,
      clay: 0,
      obsidian: 0,
      geode: 0
    }
    pp blueprint
    n_minutes.times do | minute|
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  blueprints = Parser.parse('data/day_19_sample.txt')
  pp Solution.solution(blueprints)
end
