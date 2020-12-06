package main

import (
    "strings"
    "github.com/deosjr/adventofcode2020/lib"
)

func main() {
    input := lib.ReadFile(6)
    split := strings.Split(strings.TrimSpace(input), "\n\n")
    p1, p2 := 0, 0
    for _, group := range split {
        persons := strings.Split(strings.TrimSpace(group), "\n")
        m := map[rune]int{}
        for _, person := range persons {
            added := map[rune]struct{}{}
            for _, r := range person {
                _, ok := added[r]
                if ok {
                    continue
                }
                m[r] += 1
                added[r] = struct{}{}
            }
        }
        p1 += len(m)
        for _, v := range m {
            if v == len(persons) {
                p2++
            }
        }
    }

    lib.WritePart1("%d", p1)

    lib.WritePart2("%d", p2)
}
