def calories_per_elf(input_filepath)
  File.read(input_filepath)
      .split("\n\n")
      .map { |per_elf| per_elf.scan(/\d+/).map(&:to_i) }
end

def n_calories_held_by(n_highest_holding_eleves:, calories_per_elf:)
  calories_per_elf
    .sort_by(&:sum)
    .last(n_highest_holding_eleves)
    .map(&:sum)
    .sum
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_01.txt'
  calories = calories_per_elf(input_filepath)
  pp n_calories_held_by(n_highest_holding_eleves: 1, calories_per_elf: calories)
  pp n_calories_held_by(n_highest_holding_eleves: 3, calories_per_elf: calories)
end
