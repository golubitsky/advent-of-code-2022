# frozen_string_literal: true

require 'set'

module Parser
  extend self

  def parse(filepath)
    File.readlines(filepath)
        .each_with_object({}) do |line, result|
          result[line.split[1].strip.to_sym] = {
            rate: line.scan(/\d+/).first.to_i,
            tunnels: line.split(/[vales]|[vale]/).last.split(',').map(&:strip).map(&:to_sym)
          }
        end
  end
end

module Solution
  extend self

  MINUTES = 30

  def solution(graph)
    best = backtracking_search(
      graph: graph,
      node: graph.keys.first,
      visited: Set.new,
      memo: Set.new,
      minutes_left: MINUTES,
      minute_opened_by_valve: graph.transform_values { |_| nil }
    )

    count_pressure_released(graph, best)
  end

  private

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def backtracking_search(graph:, node:, visited:, memo:, minutes_left:, minute_opened_by_valve:)
    # puts "\n#{node} min left: #{minutes_left}"
    # p minute_opened_by_valve
    return minute_opened_by_valve if
      memo.include?([node, minute_opened_by_valve]) ||
      minutes_left.zero? ||
      all_valves_with_flow_open?(graph, minute_opened_by_valve)

    memo.add([node, minute_opened_by_valve])

    best_minute_opened_by_valve = minute_opened_by_valve
    best = count_pressure_released(graph, minute_opened_by_valve)

    unless minute_opened_by_valve[node] # nothing else to explore
      # p "opening #{node}"
      # spend minute to open valve
      inner = backtracking_search(
        graph: graph,
        node: node,
        visited: visited,
        memo: memo,
        minutes_left: minutes_left - 1,
        minute_opened_by_valve: minute_opened_by_valve.merge(node => minutes_left)
      )
      cur = count_pressure_released(graph, inner)
      # puts "emerged: #{cur}"

      if cur > best
        best_minute_opened_by_valve = inner
        best = cur
      end
    end

    graph[node][:tunnels].each do |other_node|
      # p "going to #{other_node}"
      # spend minute to go to another valve
      inner = backtracking_search(
        graph: graph,
        node: other_node,
        visited: visited,
        memo: memo,
        minutes_left: minutes_left - 1,
        minute_opened_by_valve: minute_opened_by_valve
      )
      cur = count_pressure_released(graph, inner)
      # puts "emerged: #{cur}"

      if cur > best
        best_minute_opened_by_valve = inner
        best = cur
      end
    end

    best_minute_opened_by_valve
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def all_valves_with_flow_open?(graph, minute_opened_by_valve)
    graph.select { |_node, valve| valve[:rate].positive? }
         .keys
         .all? { |node| minute_opened_by_valve[node] }
  end

  def count_pressure_released(graph, minute_opened_by_valve)
    graph.map { |node, valve| (MINUTES - (minute_opened_by_valve[node] || MINUTES)) * valve[:rate] }
         .sum
  end
end
if __FILE__ == $PROGRAM_NAME
  graph = Parser.parse('data/day_16_sample.txt')
  p Solution.solution(graph)
end
