package main

import (
    "fmt"
    "strings"
    "strconv"
    "github.com/deosjr/adventofcode2020/lib"
)

func seatID(row, col int64) int64 {
    return 8 * row + col
}

type coord struct {
    x int64
    y int64
}

func main() {
    var max int64
    m := map[coord]struct{}{}
    readfunc := func(line string) {
        rows := line[:7]
        columns := line[7:]
        rows = strings.Replace(rows, "F", "0", -1)
        rows = strings.Replace(rows, "B", "1", -1)
        columns = strings.Replace(columns, "L", "0", -1)
        columns = strings.Replace(columns, "R", "1", -1)
        r, _ := strconv.ParseInt(rows, 2, 64)
        c, _ := strconv.ParseInt(columns, 2, 64)
        m[coord{x:c, y:r}] = struct{}{}
        s := seatID(r, c)
        if s > max {
            max = s
        }
    }
    lib.ReadFileByLine(5, readfunc)

    lib.WritePart1("%d", max)

    // fastest way to get p2: print all seats
    // visually inspect and multiply seatID by hand
    for y:=0; y<128; y++ {
        fmt.Printf("%3d: ", y)
        for x:=0; x<8; x++ {
            _, ok := m[coord{int64(x),int64(y)}]
            if ok {
                fmt.Print("x")
            } else {
                fmt.Print(".")
            }
        }
        fmt.Println()
    }

    //lib.WritePart2("%d", p2)
}
