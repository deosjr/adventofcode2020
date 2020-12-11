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

var ndx = []coord{ {-1, -1}, {-1, +1}, {-1, 0}, {+1, -1}, {+1, +1}, {+1, 0}, {0, -1}, {0, +1} }

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

func occupiedInView(g grid, co coord, direct bool) int {
    sum := 0
    for _, c := range ndx {
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

func runUntilStable(oldgrid grid, n int, direct bool) int {
    for {
        newgrid, more := simulate(oldgrid, n, direct)
        if !more {
            return sumOccupied(oldgrid)
        }
        oldgrid = newgrid
    }
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

func getNeighbours(g grid, co coord, direct bool) []coord {
    nns := []coord{}
    for _, c := range ndx {
        prev := co
        for {
            next := coord{prev.x + c.x, prev.y + c.y}
            n, ok := g[next]
            if !ok {
                break
            }
            if !direct && n == floor {
                prev = next
                continue
            }
            nns = append(nns, next)
            break
        }
    }
    return nns
}

func inView(oldgrid, newgrid grid, co coord, direct bool, neighbours map[coord][]coord) (permEmpty, permOccupied int) {
    nns := neighbours[co]
    permEmpty = 8 - len(nns)
    for _, c := range nns {
        switch oldgrid[c] {
        case floor:
            if direct {
                permEmpty++
            }
        case empty:
            switch newgrid[c] {
            case empty:
                permEmpty++
            case occupied:
                permOccupied++
            }
        }
    }
    return
}

// determine stable grid without simulating all frames
func stabilize(g grid, n int, direct bool) int {
    newgrid := grid{}
    newlyadded := grid{}
    // cache neighbours
    neighbours := map[coord][]coord{}
    for k, v := range g {
        if v == floor {
            newgrid[k] = floor
            continue
        }
        neighbours[k] = getNeighbours(g, k, direct)
    }
    // neighbours now contains all empty chairs
    for k, _ := range neighbours {
        empty, _ := inView(g, grid{}, k, direct, neighbours)
        if empty > 8 - n {
            newgrid[k] = occupied
            newlyadded[k] = occupied
        }
    }
    toCheck := newToCheck(g, newlyadded, newgrid, direct, neighbours)
    for len(toCheck) > 0 {
        toAdd := grid{}
        for k, _ := range toCheck {
            emp, occ := inView(g, newgrid, k, direct, neighbours)
            if occ > 0 {
                toAdd[k] = empty
            }
            if emp > 8 - n && occ == 0 {
                toAdd[k] = occupied
            }
        }
        for k, v := range toAdd {
            newgrid[k] = v
        }
        toCheck = newToCheck(g, toAdd, newgrid, direct, neighbours)
    }
    return sumOccupied(newgrid)
}

func newToCheck(g, newlyadded, newgrid grid, direct bool, neighbours map[coord][]coord) map[coord]struct{} {
    toCheck := map[coord]struct{}{}
    for k, _ := range newlyadded {
        for _, n := range neighbours[k] {
            _, ok := newgrid[n]
            if ok {
                continue
            }
            toCheck[n] = struct{}{}
        }
    }
    return toCheck
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
            }
        }
        y++
    }
    lib.ReadFileByLine(11, readfunc)

    //p1 := runUntilStable(m, 4, true)
    //lib.WritePart1("%d", p1)

    //p2 := runUntilStable(m, 5, false)
    //lib.WritePart2("%d", p2)

    // runs 3x as fast as the above
    t1 := stabilize(m, 4, true)
    lib.WritePart1("%d", t1)

    t2 := stabilize(m, 5, false)
    lib.WritePart2("%d", t2)
}
