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
                  .map { |x| x.scan(/geode|ore|clay|obsidian|\d+/) }
                  .reject(&:empty?)

    scan_by_robot = scanned.to_h { |x| [x.first, x.drop(1)] }

    scan_by_robot.to_h do |robot, scan|
      [
        robot.to_sym,
        scan.each_slice(2).map do |(cost, material)|
          { material: material.to_sym, cost: cost.to_i }
        end
      ]
    end
  end
end

module Solution
  extend self

  def solution(blueprints)
    minutes_left = 10

    blueprints[1..].each do |blueprint|
      ore_counts = {
        geode: 0,
        ore: 0,
        clay: 0,
        obsidian: 0
      }
      robot_counts = {
        geode: 0,
        ore: 1,
        clay: 0,
        obsidian: 0
      }
      $max_counts = ore_counts.dup

      pp blueprint
      exit
      simulate(blueprint, ore_counts, robot_counts, minutes_left)
      pp $max_counts
    end
  end

  def simulate(blueprint, ore_counts, robot_counts, minutes_left) # rubocop:disable Metrics/AbcSize
    if minutes_left.zero?
      if ore_counts[:geode] > $max_counts[:geode]
        $max_counts = ore_counts
      end
      return
    end

    # determine affordable robots before collecting ore
    affordable_robots = affordable_robots(blueprint, ore_counts)
    ore_counts = collect_ore(ore_counts, robot_counts)

    # possibilities: recurse with each of
    next_minute = minutes_left - 1

    # explore building each available robot
    affordable_robots.each do |robot|
      new_ore_counts, new_robot_counts =
        build_robot(robot, blueprint[robot], ore_counts, robot_counts)

      simulate(blueprint, new_ore_counts, new_robot_counts, next_minute)
    end

    # also don't build a robot
    simulate(blueprint, ore_counts, robot_counts, next_minute)
  end

  def affordable_robots(blueprint, ore_counts)
    blueprint
      .select { |_robot, robot_cost| affordable?(robot_cost, ore_counts) }
      .keys
  end

  def affordable?(robot_cost, ore_counts)
    robot_cost.all? { |material:, cost:| ore_counts[material] >= cost }
  end

  def build_robot(robot_to_build, robot_blueprint, ore_counts, robot_counts)
    new_ore_counts = ore_counts.to_h do |ore, count|
      this_ore = robot_blueprint.find { |b| b[:material] == ore }
      cost = this_ore ? this_ore[:cost] : 0

      [ore, count - cost]
    end
    new_robot_counts = robot_counts.to_h do |robot, count|
      new_count = robot == robot_to_build ? count + 1 : count

      [robot, new_count]
    end
    [new_ore_counts, new_robot_counts]
  end

  def collect_ore(ore_counts, robot_counts)
    ore_counts.to_h do |ore, count|
      [ore, count + robot_counts[ore]]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  blueprints = Parser.parse('data/day_19_sample.txt')
  pp Solution.solution(blueprints)
end
