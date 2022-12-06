package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	day, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Println("first arg must be Day int")
		os.Exit(1)
	}
	switch day {
	case 1:
		Day01()
	case 6:
		Day06()
	default:
		fmt.Println("day", os.Args[1], "is not supported")
		os.Exit(1)
	}
}
