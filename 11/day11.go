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

func simulate(old grid, nfunc func(grid, coord)int, n int) (grid, bool) {
    newgrid := grid{}
    changed := false
    for k,v := range old {
        num := nfunc(old, k)
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

func numDirectOccupied(g grid, co coord) int {
    sum := 0
    x, y := co.x, co.y
    neighbours := []coord{
        {x-1, y-1},
        {x-1, y+1},
        {x-1, y},
        {x+1, y-1},
        {x+1, y+1},
        {x+1, y},
        {x, y-1},
        {x, y+1},
    }
    for _, c := range neighbours {
        n, ok := g[c]
        if ! ok {
            continue
        }
        if n == occupied {
            sum++
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

func occupiedInView(g grid, co coord) int {
    sum := 0
    neighbours := []coord{
        {-1, -1},
        {-1, +1},
        {-1, 0},
        {+1, -1},
        {+1, +1},
        {+1, 0},
        {0, -1},
        {0, +1},
    }
    for _, c := range neighbours {
        prev := co
        for {
            next := coord{prev.x + c.x, prev.y + c.y}
            n, ok := g[next]
            if !ok {
                break
            }
            if n == empty {
                break
            }
            if n == occupied {
                sum++
                break
            }
            prev = next
        }
    }
    return sum
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

    var p1 int
    oldgrid := m
    for {
        newgrid, more := simulate(oldgrid, numDirectOccupied, 4)
        if !more {
            p1 = sumOccupied(oldgrid)
            break
        }
        oldgrid = newgrid
    }
    lib.WritePart1("%d", p1)

    var p2 int
    oldgrid = m
    for {
        newgrid, more := simulate(oldgrid, occupiedInView, 5)
        if !more {
            p2 = sumOccupied(oldgrid)
            break
        }
        oldgrid = newgrid
    }
    lib.WritePart2("%d", p2)
}
