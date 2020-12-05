package main

import (
    "strings"
    "strconv"
    "github.com/deosjr/adventofcode2020/lib"
)

func seatID(c coord) int64 {
    return 8 * c.y + c.x
}

type coord struct {
    x int64
    y int64
}

func main() {
    var p1 int64
    m := map[coord]struct{}{}
    readfunc := func(line string) {
        rows, cols := line[:7], line[7:]
        rows = strings.Replace(rows, "F", "0", -1)
        rows = strings.Replace(rows, "B", "1", -1)
        cols = strings.Replace(cols, "L", "0", -1)
        cols = strings.Replace(cols, "R", "1", -1)
        row, _ := strconv.ParseInt(rows, 2, 64)
        column, _ := strconv.ParseInt(cols, 2, 64)
        c := coord{x:column, y:row}
        m[c] = struct{}{}
        s := seatID(c)
        if s > p1 {
            p1 = s
        }
    }
    lib.ReadFileByLine(5, readfunc)

    lib.WritePart1("%d", p1)

    // fastest way to get p2: print all seats
    // visually inspect and multiply seatID by hand
    // rewritten to find the answer programmatically
    var p2 int64
Loop:
    for y:=0; y<128; y++ {
        for x:=0; x<8; x++ {
            c := coord{int64(x), int64(y)}
            _, ok := m[c]
            if ok {
                continue
            }
            cleft := coord{c.x, c.y}
            if x == 0 {
                cleft.x, cleft.y = 7, cleft.y-1
            } else {
                cleft.x = cleft.x - 1
            }
            _, okleft := m[cleft]
            cright := coord{c.x, c.y}
            if x == 7 {
                cright.x, cright.y = 0, cright.y+1
            } else {
                cright.x = cright.x + 1
            }
            _, okright := m[cright]
            if okleft && okright {
                p2 = seatID(c)
                break Loop
            }
        }
    }

    lib.WritePart2("%d", p2)
}
