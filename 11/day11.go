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

func inView(oldgrid, newgrid grid, co coord, direct bool) (permEmpty, permOccupied int) {
    for _, c := range neighbours {
        prev := co
    Loop:
        for {
            next := coord{prev.x + c.x, prev.y + c.y}
            n, ok := oldgrid[next]
            if !ok {
                permEmpty++
                break
            }
            switch n {
            case floor:
                if direct {
                    permEmpty++
                }
            case empty:
                nn, ok := newgrid[next]
                if !ok {
                    break Loop
                }
                switch nn {
                case empty:
                    permEmpty++
                case occupied:
                    permOccupied++
                case floor:
                    panic("floor should never change!")
                }
                break Loop
            case occupied:
                panic("never update oldgrid!")
            }
            if direct {
                break
            }
            prev = next
        }
    }
    return
}

// determine stable grid without simulating all frames
func stabilize(g grid, n int, direct bool) int {
    newgrid := grid{}
    toCheck := map[coord]struct{}{}
    for k,v := range g {
        if v == floor {
            // not needed but nice
            newgrid[k] = v
            continue
        }
        toCheck[k] = struct{}{}
    }
    for len(toCheck) > 0 {
        toAdd := grid{}
        for k, _ := range toCheck {
            emp, occ := inView(g, newgrid, k, direct)
            if occ > 0 {
                toAdd[k] = empty
                delete(toCheck, k)
            }
            if emp > 8 - n {
                toAdd[k] = occupied
                delete(toCheck, k)
            }
        }
        for k, v := range toAdd {
            newgrid[k] = v
        }
    }
    return sumOccupied(newgrid)
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

    //p1 := runUntilStable(m, 4, true)
    //lib.WritePart1("%d", p1)

    //p2 := runUntilStable(m, 5, false)
    //lib.WritePart2("%d", p2)

    // runs almost twice as fast
    t1 := stabilize(m, 4, true)
    lib.WritePart1("%d", t1)

    t2 := stabilize(m, 5, false)
    lib.WritePart2("%d", t2)
}
