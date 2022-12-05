module Parser
  extend self

  def pairs_of_assighments(input_filepath)
    File.readlines(input_filepath)
        .map(&:strip)
        .map { |row| assignment_pair(row) }
  end

  private

  def assignment_pair(row)
    a, b, c, d = row.scan(/\d+/).map(&:to_i)

    [
      { start: a, end: b },
      { start: c, end: d }
    ]
  end
end

module OverlappingAssighments
  extend self

  def count_full_overlaps(pairs_of_assighments)
    pairs_of_assighments.map { |pair| sorted_by_start(pair) }
                        .select { |pair| fully_overlapping?(pair) }
                        .count
  end

  def count_partial_overlaps(pairs_of_assighments)
    pairs_of_assighments.map { |pair| sorted_by_start(pair) }
                        .select { |pair| partially_overlapping?(pair) }
                        .count
  end

  private

  def sorted_by_start(assignment_pair)
    assignment_pair.sort_by { |assignment| assignment[:start] }
  end

  def fully_overlapping?(pair_sorted_by_start)
    first, second = pair_sorted_by_start

    first[:start] == second[:start] ||
      first[:end] >= second[:end]
  end

  def partially_overlapping?(pair_sorted_by_start)
    first, second = pair_sorted_by_start

    first[:end] >= second[:start]
  end
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_04.txt'

  pairs_of_assighments = Parser.pairs_of_assighments(input_filepath)
  pp OverlappingAssighments.count_full_overlaps(pairs_of_assighments)
  pp OverlappingAssighments.count_partial_overlaps(pairs_of_assighments)
end
