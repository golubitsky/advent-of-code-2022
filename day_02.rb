# frozen_string_literal: true

INPUT_FILEPATH = 'data/day_02.txt'

SHAPES_BY_PLAYED_LETTER = {
  a: :rock,
  b: :paper,
  c: :scissors,
  x: :rock,
  y: :paper,
  z: :scissors
}

SCORES_BY_SHAPE = {
  rock: 1,
  paper: 2,
  scissors: 3
}

SCORES_BY_OUTCOME = {
  lost: 0,
  draw: 3,
  won: 6
}

INDEXES_BY_PLAYER = {
  me: 1,
  opponent: 0
}

def read_rounds(input_filepath)
  File.readlines(input_filepath)
      .map(&:strip)
      .map(&:split)
      .map { |row| row.map(&:downcase).map(&:to_sym) }
end

def rounds_interpreted_for_part_one(rounds)
  rounds.map { |row| row.map { |letter| SHAPES_BY_PLAYED_LETTER[letter] } }
end

def draw?(round)
  round.uniq.size == 1
end

def outcome(round:, players_shape:)
  if draw?(round)
    :draw
  else
    other_players_shape = round.find { |shape| shape != players_shape }
    case players_shape
    when :rock
      other_players_shape == :scissors ? :won : :lost
    when :paper
      other_players_shape == :rock ? :won : :lost
    when :scissors
      other_players_shape == :paper ? :won : :lost
    end
  end
end

def score_for_part_one(round:, player:)
  players_shape = round[INDEXES_BY_PLAYER[player]]

  outcome = outcome(round: round, players_shape: players_shape)

  SCORES_BY_OUTCOME[outcome] + SCORES_BY_SHAPE[players_shape]
end

def part_one(rounds, player:)
  rounds_interpreted_for_part_one(rounds)
    .map { |round| score_for_part_one(round: round, player: player) }
    .sum
end

module PartTwo
  extend self

  PART_TWO_DESIRED_OUTCOME_BY_LETTER = {
    x: :lost,
    y: :draw,
    z: :won
  }

  PART_TWO_INDEXES_BY_MEANING = {
    desired_outcome: 1,
    opponent: 0
  }

  def part_two(rounds)
    rounds_interpreted_for_part_two(rounds)
      .map { |round| score_for_part_two(round: round) }
      .sum
  end

  private

  def score_for_part_two(round:)
    desired_outcome = round[PART_TWO_INDEXES_BY_MEANING[:desired_outcome]]
    other_players_shape = round[INDEXES_BY_PLAYER[:opponent]]

    my_shape = shape_required_for_outcome(
      other_players_shape: other_players_shape,
      desired_outcome: desired_outcome
    )

    score_for_part_one(round: [other_players_shape, my_shape], player: :me)
  end

  def shape_required_for_outcome(other_players_shape:, desired_outcome:)
    case desired_outcome
    when :won
      {
        rock: :paper,
        paper: :scissors,
        scissors: :rock
      }[other_players_shape]
    when :lost
      {
        rock: :scissors,
        paper: :rock,
        scissors: :paper
      }[other_players_shape]
    when :draw
      other_players_shape
    end
  end

  def rounds_interpreted_for_part_two(rounds)
    rounds.map do |row|
      row.map do |letter|
        PART_TWO_DESIRED_OUTCOME_BY_LETTER[letter] ||
          SHAPES_BY_PLAYED_LETTER[letter]
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  rounds = read_rounds(INPUT_FILEPATH)
  puts part_one(rounds, player: :me)
  puts PartTwo.part_two(rounds)
end
