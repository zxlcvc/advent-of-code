package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func best2(s string) int {
	best := -1
	n := len(s)
	for i := 0; i < n-1; i++ {
		a := int(s[i] - '0')
		for j := i + 1; j < n; j++ {
			b := int(s[j] - '0')
			v := a*10 + b
			if v > best && v%4 == 0 {
				best = v
			}
		}
	}
	return best
}

func best12(s string) int64 {
	k := 12
	res := int64(0)
	start := 0
	n := len(s)

	for pick := 0; pick < k; pick++ {
		end := n - (k - pick) + 1
		bestDigit := byte('0')
		bestIdx := start

		for i := start; i < end; i++ {
			if s[i] > bestDigit {
				bestDigit = s[i]
				bestIdx = i
			}
		}

		res = res*10 + int64(bestDigit-'0')
		start = bestIdx + 1

	}
	return res
}
func main() {
	f, err := os.Open("input3.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	part1 := 0
	var part2 int64 = 0
	for sc.Scan() {
		line := sc.Text()
		part1 += best2(line)
		part2 += best12(line)
	}
	fmt.Println("Part 1:", part1)
	fmt.Println("Part 2:", part2)
}
