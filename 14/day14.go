package main

import (
    "fmt"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func to36BitString(n int64) string {
    return fmt.Sprintf("%036b", n)
}

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

func part1(mask string, value int64) int64 {
    valuestring := to36BitString(value)
    var str string
    for i, k := range mask {
        if k != 'X' {
            str += string(k)
            continue
        }
        str += string(valuestring[i])
    }
    return mustParseInt(str)
}

func part2(mask string, address int64) []int64 {
    addressstring := to36BitString(address)
    var newstrs []string
    strs := []string{""}
    for i, k := range mask {
        switch k {
        case 'X':
            for _, str := range strs {
                newstrs = append(newstrs, str + "0")
            }
            for _, str := range strs {
                newstrs = append(newstrs, str + "1")
            }
        case '1':
            for _, str := range strs {
                newstrs = append(newstrs, str + "1")
            }
        case '0':
            for _, str := range strs {
                newstrs = append(newstrs, str + string(addressstring[i]))
            }
        }
        strs = make([]string, len(newstrs))
        copy(strs, newstrs)
        newstrs = nil
    }
    out := make([]int64, len(strs))
    for i, str := range strs {
        out[i] = mustParseInt(str)
    }
    return out
}

func main() {
    var mask string
    mem1 := map[int64]int64{}
    mem2 := map[int64]int64{}
    readfunc := func(line string) {
        if strings.HasPrefix(line, "mask") {
            fmt.Sscanf(line, "mask = %s", &mask)
            return
        }
        var address, value int64
        fmt.Sscanf(line, "mem[%d] = %d", &address, &value)
        v := part1(mask, value)
        mem1[address] = v
        for _, adr := range part2(mask, address) {
            mem2[adr] = value
        }
    }
    lib.ReadFileByLine(14, readfunc)

    p1 := sumValues(mem1)
    lib.WritePart1("%d", p1)

    p2 := sumValues(mem2)
    lib.WritePart2("%d", p2)
}
