package main

import (
    "github.com/deosjr/adventofcode2020/lib"
)

type coord struct {
    x int
    y int
}

type cell uint8

const (
    floor cell = iota
    empty
    occupied
)

type grid map[coord]cell

func simulate(old grid, n int, direct bool) (grid, bool) {
    newgrid := grid{}
    changed := false
    for k,v := range old {
        num := occupiedInView(old, k, direct)
        if num == 0 && v == empty {
            newgrid[k] = occupied
            changed = true
            continue
        }
        if num >= n && v == occupied {
            newgrid[k] = empty
            changed = true
            continue
        }
        newgrid[k] = v
    }
    return newgrid, changed
}

var neighbours = []coord{ {-1, -1}, {-1, +1}, {-1, 0}, {+1, -1}, {+1, +1}, {+1, 0}, {0, -1}, {0, +1} }

func occupiedInView(g grid, co coord, direct bool) int {
    sum := 0
    for _, c := range neighbours {
        prev := co
        for {
            next := coord{prev.x + c.x, prev.y + c.y}
            n, ok := g[next]
            if !ok {
                break
            }
            if n == occupied {
                sum++
                break
            }
            if n == empty || direct {
                break
            }
            prev = next
        }
    }
    return sum
}

func sumOccupied(g grid) int {
    sum := 0
    for _, v := range g {
        if v == occupied {
            sum++
        }
    }
    return sum
}

func runUntilStable(oldgrid grid, n int, direct bool) int {
    for {
        newgrid, more := simulate(oldgrid, n, direct)
        if !more {
            return sumOccupied(oldgrid)
        }
        oldgrid = newgrid
    }
}

func main() {
    m := grid{}
    y := 0
    readfunc := func(line string) {
        for x, c := range line {
            switch c {
            case '.':
                m[coord{x:x, y:y}] = floor
            case 'L':
                m[coord{x:x, y:y}] = empty
            case '#':
                m[coord{x:x, y:y}] = occupied
            }
        }
        y++
    }
    lib.ReadFileByLine(11, readfunc)

    p1 := runUntilStable(m, 4, true)
    lib.WritePart1("%d", p1)

    p2 := runUntilStable(m, 5, false)
    lib.WritePart2("%d", p2)
}
