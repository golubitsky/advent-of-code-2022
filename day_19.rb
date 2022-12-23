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

module Solution
  extend self

  def solution(blueprints)
    blueprints.each do |blueprint|
      simulate(blueprint)
      exit
    end
  end

  def simulate(blueprint)
    pp blueprint
  end
end

if __FILE__ == $PROGRAM_NAME
  blueprints = Parser.parse('data/day_19_sample.txt')
  pp Solution.solution(blueprints)
end
