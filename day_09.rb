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
    head_motion_unit_vectors.each.with_index do |head_motion_vector, index|
      knots[0] += head_motion_vector
      puts "head after move #{knots[0]}"
      update_knots_after_head_move!(knots)

      visited_by_tail.add(knots.last)

      puts 'tails updated; end of iteration'
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
      puts "after #{i + 1} updated: #{knots}"

      i += 1
    end
  end

  def follower_motion_vector(lead_knot:, follower_knot:)
    # After each step, you'll need to update the position of the tail
    # if the step means the head is no longer adjacent to the tail.

    case lead_knot - follower_knot
    # If the head is ever two steps directly up, down, left, or right from the tail,
    # the tail must also move one step in that direction so it remains close enough
    when Vector[2, 0]
      Vector[1, 0]
    when Vector[-2, 0]
      Vector[-1, 0]
    when Vector[0, 2]
      Vector[0, 1]
    when Vector[0, -2]
      Vector[0, -1]
    # Otherwise, if the head and tail aren't touching and aren't in the same row or column,
    # the tail always moves one step diagonally to keep up
    when Vector[1, 2]
      Vector[1, 1]
    when Vector[-1, -2]
      Vector[-1, -1]
    when Vector[-1, 2]
      Vector[-1, 1]
    when Vector[1, -2]
      Vector[1, -1]
    when Vector[2, 1]
      Vector[1, 1]
    when Vector[-2, -1]
      Vector[-1, -1]
    when Vector[2, -1]
      Vector[1, -1]
    when Vector[-2, 1]
      Vector[-1, 1]
    else
      Vector[0, 0]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  head_motion_unit_vectors =
    Parser.parse_head_motions_as_unit_vectors('data/day_09_test.txt')
  # pp Solution.solution(head_motion_unit_vectors, knots: 2)
  pp Solution.solution(head_motion_unit_vectors, knots: 10)
end
