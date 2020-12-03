package main

import (
    "github.com/deosjr/adventofcode2020/lib"
)

type coord struct {
    x int
    y int
}

func checkTrees(m map[coord]struct{}, maxx, maxy, incrx, incry int) int {
    trees := 0
    pc := coord{0,0}
    for {
        y := pc.y + incry
        if y >= maxy {
            break
        }
        x := (pc.x + incrx) % maxx
        pc = coord{x:x, y:y}
        if _, ok := m[pc]; ok {
            trees++
        }
    }
    return trees
}

func main() {
    maxx, maxy := 0, 0
    m := map[coord]struct{}{}
    readfunc := func(line string) {
        maxx = len(line)
        for x, c := range line {
            if c != '#' {
                continue
            }
            m[coord{x:x, y:maxy}] = struct{}{}
        }
        maxy++
    }
    lib.ReadFileByLine(3, readfunc)

    r3d1 := checkTrees(m, maxx, maxy, 3, 1)
    lib.WritePart1("%d", r3d1)

    r1d1 := checkTrees(m, maxx, maxy, 1, 1)
    r5d1 := checkTrees(m, maxx, maxy, 5, 1)
    r7d1 := checkTrees(m, maxx, maxy, 7, 1)
    r1d2 := checkTrees(m, maxx, maxy, 1, 2)
    p2 := r1d1 * r3d1 * r5d1 * r7d1 * r1d2
    lib.WritePart2("%d", p2)
}
