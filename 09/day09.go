package main

import (
	"math"

	"github.com/deosjr/adventofcode2020/lib"
)

// find two values in m that sum to n
func find(m map[int64]struct{}, n int64) bool {
	for k, _ := range m {
		v := n - k
		if _, ok := m[v]; ok {
			return true
		}
	}
	return false
}

func main() {
	list := []int64{}
	readfunc := func(line string) {
		n := lib.MustParseInt(line)
		list = append(list, n)
	}
	lib.ReadFileByLine(9, readfunc)

	preamble := list[:25]
	m := map[int64]struct{}{}
	for _, n := range preamble {
		m[n] = struct{}{}
	}

	var p1 int64
	for i, n := range list[25:] {
		if !find(m, n) {
			p1 = n
			break
		}
		delete(m, list[i])
		m[list[i+25]] = struct{}{}
	}
	lib.WritePart1("%d", p1)

	smallest := func(a, b int) int64 {
		var min int64 = math.MaxInt64
		var max int64 = 0
		for i := a; i <= b; i++ {
			n := list[i]
			if n > max {
				max = n
			}
			if n < min {
				min = n
			}
		}
		return min + max
	}

	var p2 int64
Loop:
	for i := 0; i < len(list); i++ {
		sum := list[i]
		for j := i + 1; j < len(list); j++ {
			sum += list[j]
			if sum == p1 {
				p2 = smallest(i, j)
				break
			}
			if sum > p1 {
				continue Loop
			}
		}
	}

	lib.WritePart2("%d", p2)
}
