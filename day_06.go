package main

import "fmt"

func isStartOfPacketMarker(s string) bool {
	seenChars := make(map[byte]bool)

	for i := 0; i < len(s); i++ {
		if seenChars[s[i]] {
			return false
		} else {
			seenChars[s[i]] = true
		}
	}

	return true
}

func nCharsNeededToReceiveUniqueMarker(datastreamBuffer string, markerLength int) int {
	for i := 0; i <= len(datastreamBuffer)-markerLength; i++ {
		if isStartOfPacketMarker(datastreamBuffer[i : i+markerLength]) {
			return i + markerLength
		}
	}
	return 0
}

func Day06() {
	datastreamBuffer := ReadLines("data/day_06.txt")[0]

	fmt.Println("part 1", nCharsNeededToReceiveUniqueMarker(datastreamBuffer, 4))
	fmt.Println("part 2", nCharsNeededToReceiveUniqueMarker(datastreamBuffer, 14))
}
