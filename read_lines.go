package main

import (
	"bufio"
	"fmt"
	"os"
)

func ReadLines(filepath string) []string {
	readFile, err := os.Open(filepath)

	if err != nil {
		fmt.Println(err)
	}
	fileScanner := bufio.NewScanner(readFile)

	fileScanner.Split(bufio.ScanLines)

	var lines []string

	for fileScanner.Scan() {
		lines = append(lines, fileScanner.Text())
	}

	readFile.Close()

	return lines
}
