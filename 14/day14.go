package main

import (
    "fmt"
    "math"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func sumValues(m map[int64]int64) (sum int64) {
    for _, v := range m {
        sum += v
    }
    return sum
}

func mustParseInt(str string) int64 {
    v, err := strconv.ParseInt(str, 2, 64)
    if err != nil {
        panic(err)
    }
    return v
}

func part1(maskX, mask1, value int64) int64 {
    return (value & maskX) | mask1
}

func part2(maskX, maskXs, mask1, address int64) int64 {
    return ((address | mask1) | maskX) ^ maskXs
}

func main() {
    var maskX int64
    var mask1 int64
    var maskXs []int64
    mem1 := map[int64]int64{}
    mem2 := map[int64]int64{}
    readfunc := func(line string) {
        if strings.HasPrefix(line, "mask") {
            var maskstr string
            fmt.Sscanf(line, "mask = %s", &maskstr)
            maskX = mustParseInt(strings.Replace(strings.Replace(maskstr, "1", "0", -1), "X", "1", -1))
            mask1 = mustParseInt(strings.Replace(maskstr, "X", "0", -1))
            maskXs = nil
            var xs []int64
            for i, s := range maskstr {
                if s != 'X' {
                    continue
                }
                exp := float64(len(maskstr)-1-i)
                xs = append(xs, int64(math.Pow(2, exp)))
            }
            newxs := []int64{0, xs[0]}
            var newnew []int64
            for _, x := range xs[1:] {
                for _, v := range newxs {
                    newnew = append(newnew, v)
                    newnew = append(newnew, v + x)
                }
                newxs = make([]int64, len(newnew))
                copy(newxs, newnew)
                newnew = nil
            }
            maskXs = newxs
            return
        }
        var address, value int64
        fmt.Sscanf(line, "mem[%d] = %d", &address, &value)
        v := part1(maskX, mask1, value)
        mem1[address] = v

        for _, m := range maskXs {
            adr := part2(maskX, m, mask1, address)
            mem2[adr] = value
        }
    }
    lib.ReadFileByLine(14, readfunc)

    p1 := sumValues(mem1)
    lib.WritePart1("%d", p1)

    p2 := sumValues(mem2)
    lib.WritePart2("%d", p2)
}
