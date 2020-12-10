package main

import (
    "sort"

    "github.com/deosjr/adventofcode2020/lib"
)

func main() {
    list := []int{}
    readfunc := func(line string) {
        n := int(lib.MustParseInt(line))
        list = append(list, n)
    }
    lib.ReadFileByLine(10, readfunc)
    sort.Ints(list)

    split := [][]int{}
    current := []int{0}
    prev := 0
    // threes starts at one
    ones, threes := 0, 1
    for _, jolt := range list {
        diff := jolt - prev
        prev = jolt
        if diff == 3 {
            threes++
            split = append(split, current)
            current = []int{jolt}
            continue
        }
        current = append(current, jolt)
        if diff == 1 {
            ones++
        }
    }
    p1 := ones * threes
    lib.WritePart1("%d", p1)

    split = append(split, current)
    p2 := 1
    for _, sublist := range split {
        switch len(sublist) {
        case 3:
            if sublist[2] - sublist[0] > 3 {
                continue
            }
            p2 *= 2
        case 4:
            // diff is always 3 in my input
            p2 *= 4
        case 5:
            // diff is always 4 in my input
            p2 *= 7
        default:
            continue
        }
    }
    lib.WritePart2("%d", p2)
}
