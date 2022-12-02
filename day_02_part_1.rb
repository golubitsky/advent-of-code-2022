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

def read_played_rounds(input_filepath)
  File.readlines(input_filepath)
      .map(&:strip)
      .map(&:split)
      .map { |row| row.map(&:downcase).map(&:to_sym) }
      .map { |row| row.map { |letter| SHAPES_BY_PLAYED_LETTER[letter] } }
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

def score(round:, player:)
  players_shape = round[INDEXES_BY_PLAYER[player]]

  outcome = outcome(round: round, players_shape: players_shape)

  SCORES_BY_OUTCOME[outcome] + SCORES_BY_SHAPE[players_shape]
end

if __FILE__ == $PROGRAM_NAME
  pp read_played_rounds(INPUT_FILEPATH)
    .map { |round| score(round: round, player: :me) }
    .sum
end
