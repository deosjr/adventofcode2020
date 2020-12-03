package main

import (
    "github.com/deosjr/adventofcode2020/lib"
)

// find two values in m that sum to n
// if ignore is not -1, ignore key 'ignore' in m
// returns the product of the two values found
func find(m map[int64]struct{}, n, ignore int64) (int64, bool) {
    for k, _ := range m {
        if k == ignore {
            continue
        }
        v := n - k
        if _, ok := m[v]; ok {
            return k * v, true
        }
    }
    return -1, false
}

func main() {
    m := map[int64]struct{}{}
    readfunc := func(line string) {
        n := lib.MustParseInt(line)
        m[n] = struct{}{}
    }
    lib.ReadFileByLine(1, readfunc)

    p1, _ := find(m, 2020, -1)
    lib.WritePart1("%d", p1)

    for k, _ := range m {
        p2, ok := find(m, 2020 - k, k)
        if ok {
            lib.WritePart2("%d", k * p2)
            break
        }
    }
}
