# frozen_string_literal: true

def debug_print(string)
  print string if ENABLE_DEBUG_LOGS
end

def debug_puts(string)
  puts string if ENABLE_DEBUG_LOGS
end

module ForestViewer
  extend self

  def number_of_visible_trees(forest)
    number_of_visible_trees = 0

    forest.each_with_index do |row, row_index|
      row.each_with_index do |_tree_height, col_index|
        number_of_visible_trees += 1 if visible?(forest, row_index, col_index)
      end
    end

    number_of_visible_trees
  end

  def highest_scenic_score(forest)
    highest_scenic_score = 0

    forest.each_with_index do |row, row_index|
      row.each_with_index do |tree_height, col_index|
        west_score = 0
        east_score = 0
        north_score = 0
        south_score = 0
        # look west
        i = col_index - 1
        while i >= 0
          west_score += 1
          break if forest[row_index][i] >= tree_height

          i -= 1
        end

        # look east
        i = col_index + 1
        while i < row_size(forest)
          east_score += 1
          break if forest[row_index][i] >= tree_height

          i += 1
        end

        # look north
        i = row_index - 1
        while i >= 0
          north_score += 1
          break if forest[i][col_index] >= tree_height

          i -= 1
        end

        # look north
        i = row_index + 1
        while i < col_size(forest)
          south_score += 1
          break if forest[i][col_index] >= tree_height

          i += 1
        end

        cur_scenic_score = [east_score, west_score, south_score, north_score].reduce(:*)
        highest_scenic_score = cur_scenic_score if cur_scenic_score > highest_scenic_score
      end
    end

    highest_scenic_score
  end

  private

  def visible?(forest, row_index, col_index)
    at_edge_of_forest?(forest, row_index, col_index) ||
      visible_from_west?(forest, row_index, col_index) ||
      visible_from_east?(forest, row_index, col_index) ||
      visible_from_north?(forest, row_index, col_index) ||
      visible_from_south?(forest, row_index, col_index)
  end

  def at_edge_of_forest?(forest, row_index, col_index)
    row_index.zero? || # north edge
      col_index.zero? || # west edge
      col_index + 1 == row_size(forest) || # east edge
      row_index + 1 == col_size(forest) # south edge
  end

  def visible_from_west?(forest, row_index, col_index)
    debug_print "visible_from_west? #{row_index} #{col_index} -> "

    tree_height = forest[row_index][col_index]

    i = col_index - 1
    while i >= 0
      if forest[row_index][i] >= tree_height
        debug_puts "no (tree_height: #{tree_height})"
        return false
      end

      i -= 1
    end

    debug_puts "yes (tree_height: #{tree_height})"
    true
  end

  def visible_from_east?(forest, row_index, col_index)
    debug_print "visible_from_east? #{row_index} #{col_index} -> "

    tree_height = forest[row_index][col_index]

    i = col_index + 1
    while i < row_size(forest)
      if forest[row_index][i] >= tree_height
        debug_puts "no (tree_height: #{tree_height})"
        return false
      end

      i += 1
    end

    debug_puts "yes (tree_height: #{tree_height})"
    true
  end

  def visible_from_north?(forest, row_index, col_index)
    debug_print "visible_from north? #{row_index} #{col_index} -> "

    tree_height = forest[row_index][col_index]

    i = row_index - 1
    while i >= 0
      if forest[i][col_index] >= tree_height
        debug_puts "no (tree_height: #{tree_height})"
        return false
      end

      i -= 1
    end

    debug_puts "yes (tree_height: #{tree_height})"
    true
  end

  def visible_from_south?(forest, row_index, col_index)
    debug_print "visible_from south? #{row_index} #{col_index} -> "

    tree_height = forest[row_index][col_index]

    i = row_index + 1
    while i < col_size(forest)
      if forest[i][col_index] >= tree_height
        debug_puts "no (tree_height: #{tree_height})"
        return false
      end

      i += 1
    end

    debug_puts "yes (tree_height: #{tree_height})"
    true
  end

  def row_size(forest)
    forest.first.length
  end

  def col_size(forest)
    forest.length
  end
end

if __FILE__ == $PROGRAM_NAME
  ENABLE_DEBUG_LOGS = false

  forest = File.readlines('data/day_08.txt')
               .map(&:strip)
               .map(&:chars)
               .map { |x| x.map(&:to_i) }

  puts ForestViewer.number_of_visible_trees(forest)
  puts ForestViewer.highest_scenic_score(forest)
end
