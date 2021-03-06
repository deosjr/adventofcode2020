package main

import (
    "math"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func main() {
    input := lib.ReadFile(13)
    split := strings.Split(input, "\n")
    var min int64 = math.MaxInt64
    var p1 int64
    myTimestamp := lib.MustParseInt(split[0])
    buses := []int64{}
    indices := []int{}
    busesp2 := map[int]int64{}
    for i, s := range strings.Split(split[1], ",") {
        if s == "x" {
            continue
        }
        bus := lib.MustParseInt(s)
        buses = append(buses, bus)
        minutesToWait := bus - (myTimestamp % bus)
        if minutesToWait < min {
            min = minutesToWait
            p1 = minutesToWait * bus
        }
        busesp2[i] = bus
        if i == 0 {
            continue
        }
        indices = append(indices, i)
    }

    lib.WritePart1("%d", p1)

    var t int64 = 0
    n1 := busesp2[0]
    for _, i := range indices {
        var j int64
        for {
            j++
            jin := t + int64(j)*n1
            test := (jin + int64(i)) % busesp2[i]
            if test != 0 {
                continue
            }
            t = jin
            n1 = n1 * busesp2[i]
            break
        }
    }

    lib.WritePart2("%d",  t)
}
