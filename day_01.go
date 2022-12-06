package main

import (
	"fmt"
	"strconv"
)

type threeHighestCalorieCounts struct {
	first  int64
	second int64
	third  int64
}

func threeHighestCalorieCountsPerElf(lines []string) threeHighestCalorieCounts {
	var currentElfCalorieCount int64
	highest := threeHighestCalorieCounts{0, 0, 0}

	for _, line := range lines {
		if len(line) > 0 { // https://pkg.go.dev/builtin
			calories, _ := strconv.ParseInt(line, 10, 64)
			currentElfCalorieCount += calories
		} else {
			highest = updatedMaxThree(highest, currentElfCalorieCount)
			currentElfCalorieCount = 0
		}
	}

	// ensure the last elf gets counted
	highest = updatedMaxThree(highest, currentElfCalorieCount)

	return highest
}

func updatedMaxThree(high threeHighestCalorieCounts, cur int64) threeHighestCalorieCounts {
	if cur > high.first {
		high.third = high.second
		high.second = high.first
		high.first = cur
	} else if cur > high.second {
		high.third = high.second
		high.second = cur
	} else if cur > high.third {
		high.third = cur
	}
	return high
}

func Day01() {
	var lines = ReadLines("data/day_01.txt")
	var threeHighest = threeHighestCalorieCountsPerElf(lines)
	fmt.Println("elf with most calories has", threeHighest.first, "calories")
	fmt.Println("altogether, three elves with most calories have", sum(threeHighest), "calories")
}
