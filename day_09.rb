# frozen_string_literal: true

require 'matrix'
require 'set'

module Parser
  extend self

  def parse_head_motions_as_unit_vectors(filepath)
    File.readlines(filepath)
        .map(&:strip)
        .map(&:split)
        .map { |motion| { direction: motion[0], steps: motion[1].to_i } }
        .flat_map { |motion| head_motion_unit_vectors(motion) }
  end

  private

  def head_motion_unit_vectors(motion)
    Array.new(motion[:steps]) do
      {
        'R' => Vector[1, 0],
        'D' => Vector[0, -1],
        'L' => Vector[-1, 0],
        'U' => Vector[0, 1]
      }[motion[:direction]]
    end
  end
end

module Solution
  extend self

  def solution(head_motion_unit_vectors, knots:)
    knots = Array.new(knots) { Vector[0, 0] } # tail is last index

    visited_by_tail = Set.new
    visited_by_tail.add(knots.last)
    head_motion_unit_vectors.each do |head_motion_vector|
      knots[0] += head_motion_vector

      update_knots_after_head_move!(knots)

      visited_by_tail.add(knots.last)
      draw_state(knots) if DRAW_STATE_FOR_DEBUGGING
    end

    visited_by_tail.size
  end

  private

  def update_knots_after_head_move!(knots)
    i = 0

    while i < knots.length - 1
      lead_knot = knots[i]
      follower_knot = knots[i + 1]

      knots[i + 1] += follower_motion_vector(
        lead_knot: lead_knot,
        follower_knot: follower_knot
      )

      i += 1
    end
  end

  def follower_motion_vector(lead_knot:, follower_knot:)
    diff = lead_knot - follower_knot

    if diff.map(&:abs).max <= 1
      # After each step, you'll need to update the position of the tail
      # if the step means the head is no longer adjacent to the tail.
      Vector[0, 0] # in this branch it _is_ adjacent, so don't move the follower
    elsif diff.include?(0)
      # If the head is ever two steps directly up, down, left, or right from the tail,
      # the tail must also move one step in that direction so it remains close enough
      diff.map { |x| x.zero? ? 0 : x / x.abs }
    else
      # Otherwise, if the head and tail aren't touching and aren't in the same row or column,
      # the tail always moves one step diagonally to keep up
      diff.map { |x| x / x.abs }
    end
  end

  def draw_state(knots)
    rows = 5
    cols = 6
    dots = Array.new(rows) { Array.new(cols) { '.' } }
    dots[0][0] = 's'
    head, *rest = knots
    rest.each_with_index.to_a.reverse.each do |(knot, index)|
      dots[knot[1]][knot[0]] = (index + 1).to_s
    end
    dots[head[1]][head[0]] = 'H'
    puts dots.reverse.map(&:join)
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  DRAW_STATE_FOR_DEBUGGING = false

  head_motion_unit_vectors =
    Parser.parse_head_motions_as_unit_vectors('data/day_09.txt')

  pp Solution.solution(head_motion_unit_vectors, knots: 2)
  pp Solution.solution(head_motion_unit_vectors, knots: 10)
end
