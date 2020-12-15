package main

import (
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func say(array []int, n int64, turn int) (newn int64) {
    prevturn := array[int(n)]
    if prevturn == 0 {
        newn = 0
    } else {
        newn = int64(turn - prevturn)
    }
    array[int(n)] = turn
    return newn
}

func main() {
    input := lib.ReadFile(15)
    split := strings.Split(strings.TrimSpace(input), ",")

    turn := 1
    var newn int64
    // using an array is faster than a map here due to distribution of keys
    // some people even use a map for the high keys, cause those are sparse
    array := make([]int, 30_000_000)
    for _, s := range split {
        n := lib.MustParseInt(s)
        newn = say(array, n, turn)
        turn++
    }

    for i:=turn; i<2020; i++ {
        newn = say(array, newn, turn)
        turn++
    }

    p1 := newn
    lib.WritePart1("%d", p1)


    for i:=turn; i<30_000_000; i++ {
        newn = say(array, newn, turn)
        turn++
    }

    p2 := newn
    lib.WritePart2("%d", p2)
}
