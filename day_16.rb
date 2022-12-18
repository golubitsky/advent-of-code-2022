# frozen_string_literal: true

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .each_with_object({}) do |line, result|
          result[line.split[1].strip.to_sym] = {
            rate: line.scan(/\d+/).first.to_i,
            tunnels: line.split(/[valves]|[valve]/).last.split(',').map(&:strip).map(&:to_sym),
            opened_during_minute: nil
          }
        end
  end
end

module Solution
  extend self

  RESULT = []
  $explored_count = 0
  def solution(state)
    backtracking_search(minute: 1, valve_name: state.keys.first, state: state)
    RESULT.map { |state| count_pressure_released(state) }.sort.last(5)
  end

  private

  def backtracking_search(minute:, valve_name:, state:)
    $explored_count += 1
    p $explored_count if $explored_count % 1_000_000 == 0
    if minute == 31
      RESULT << state
      return
    end
    if all_valves_with_flow_open?(state)
      p state
      p count_pressure_released(state)
      RESULT << state
      return
    end

    # TODO: need better heuristic to determine which edge to go to first.
    # TODO: detect cycles? e.g. makes no sense to keep hopping back and forth
    # between :II and :JJ ad infinitum. And there are larger cycles. Cycles
    # of valves already open.
    unless state[valve_name][:opened_during_minute] # nothing else to explore
      backtracking_search(
        minute: minute + 1,
        valve_name: valve_name, # stay here, spend minute to open valve
        state: state.merge(
          valve_name => state[valve_name].merge(opened_during_minute: minute)
        )
      )
    end

    # explore the highest rate valves first
    sorted = state[valve_name][:tunnels].sort_by { |to| -state[to][:rate] }
    sorted.each do |to_valve|
      # spend minute to go to another valve
      backtracking_search(minute: minute + 1, valve_name: to_valve, state: state)
    end
  end

  def all_valves_with_flow_open?(state)
    state.values
         .select { |valve| valve[:rate].positive? }
         .all? { |valve| valve[:opened_during_minute] }
  end

  def count_pressure_released(state)
    state.values
         .select { |valve| valve[:rate].positive? }
         .map { |valve| (30 - (valve[:opened_during_minute] || 30)) * valve[:rate] }
         .sum
  end
end

if __FILE__ == $PROGRAM_NAME
  parsed = Parser.parse('data/day_16_sample.txt')
  pp Solution.solution(parsed)
end
