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
      row.each_with_index do |_col, col_index|
        number_of_visible_trees += 1 if visible?(forest, row_index, col_index)
      end
    end

    number_of_visible_trees
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

    cur_height = forest[row_index][col_index]

    i = col_index - 1
    while i >= 0
      if forest[row_index][i] >= cur_height
        debug_puts "no (cur_height: #{cur_height})"
        return false
      end

      i -= 1
    end

    debug_puts "yes (cur_height: #{cur_height})"
    true
  end

  def visible_from_east?(forest, row_index, col_index)
    debug_print "visible_from_east? #{row_index} #{col_index} -> "

    cur_height = forest[row_index][col_index]

    i = col_index + 1
    while i < row_size(forest)
      if forest[row_index][i] >= cur_height
        debug_puts "no (cur_height: #{cur_height})"
        return false
      end

      i += 1
    end

    debug_puts "yes (cur_height: #{cur_height})"
    true
  end

  def visible_from_north?(forest, row_index, col_index)
    debug_print "visible_from north? #{row_index} #{col_index} -> "

    cur_height = forest[row_index][col_index]

    i = row_index - 1
    while i >= 0
      if forest[i][col_index] >= cur_height
        debug_puts "no (cur_height: #{cur_height})"
        return false
      end

      i -= 1
    end

    debug_puts "yes (cur_height: #{cur_height})"
    true
  end

  def visible_from_south?(forest, row_index, col_index)
    debug_print "visible_from south? #{row_index} #{col_index} -> "

    cur_height = forest[row_index][col_index]

    i = row_index + 1
    while i < col_size(forest)
      if forest[i][col_index] >= cur_height
        debug_puts "no (cur_height: #{cur_height})"
        return false
      end

      i += 1
    end

    debug_puts "yes (cur_height: #{cur_height})"
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

  pp ForestViewer.number_of_visible_trees(forest)
end
