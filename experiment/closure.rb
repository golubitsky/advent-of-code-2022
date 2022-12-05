def initialize_multiplier(multiplier)
  ->(x) { x * multiplier }
end

multiply_by_four = initialize_multiplier(4)
multiply_by_five = initialize_multiplier(5)

raise unless multiply_by_four.call(3) == 12
raise unless multiply_by_five.call(3) == 15