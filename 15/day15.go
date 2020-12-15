package main

import (
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func say(m map[int64]int, n int64, turn int) (newn int64) {
    if prevturn, ok := m[n]; ok {
        newn = int64(turn - prevturn)
    } else {
        newn = 0
    }
    m[n] = turn
    return newn
}

func main() {
    input := lib.ReadFile(15)
    split := strings.Split(strings.TrimSpace(input), ",")

    turn := 1
    var newn int64
    m := map[int64]int{}
    for _, s := range split {
        n := lib.MustParseInt(s)
        newn = say(m, n, turn)
        turn++
    }

    for i:=turn; i<2020; i++ {
        newn = say(m, newn, turn)
        turn++
    }

    p1 := newn
    lib.WritePart1("%d", p1)


    for i:=turn; i<30000000; i++ {
        newn = say(m, newn, turn)
        turn++
    }

    p2 := newn
    lib.WritePart2("%d", p2)
}
