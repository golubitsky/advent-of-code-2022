package main

import (
	"fmt"
)

func add(x int, y int) int {
	return x + y
}

type person struct {
	age  int
	name string
}

func demo() {
	x := 4
	y := 5
	array := []int{1, 2, 3, 4, 5}
	array = append(array, 13)

	number_by_string := make(map[string]int)
	number_by_string["one"] = 1
	number_by_string["two"] = 2
	number_by_string["three"] = 3

	for i := 0; i < 3; i++ {
		if x > y {
			fmt.Println("x is greater than y")
		} else if x < y {
			fmt.Println("x is less than y")
		} else {
			fmt.Println("x equals y")
			array[2] = 56
			fmt.Println(array)
			fmt.Println(number_by_string["three"])
			delete(number_by_string, "two")
			fmt.Println(number_by_string)
		}
		x++
	}

	for key, value := range number_by_string {
		fmt.Println("key:", key, "value:", value)
		break
	}
	for index, value := range array {
		fmt.Println("index:", index, "value:", value)
		break
	}

	fmt.Println("two plus two equals", add(2, 2))

	p := person{name: "Mikhail", age: 37}

	fmt.Println(p, p.name, p.age)
}
func main() {
	var lines = readLines("data/day_01_sample.txt")

	for index, value := range lines {
		fmt.Println(index, value)
	}

}
