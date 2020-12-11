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

// the function that does everything (bad, I know..):
// look at all directions, count neighbours we know are empty/occupied
// also returns all neighbours it considered
func inView(oldgrid, newgrid grid, co coord, direct bool) (permEmpty, permOccupied int, nns []coord) {
    for _, c := range neighbours {
        prev := co
        for {
            next := coord{prev.x + c.x, prev.y + c.y}
            n, ok := oldgrid[next]
            if !ok {
                permEmpty++
                break
            }
            if newgrid == nil {
                nns = append(nns, next)
            }
            if !direct && n == floor {
                prev = next
                continue
            }
            if newgrid == nil {
                break
            }
            switch n {
            case floor:
                if direct {
                    permEmpty++
                }
            case empty:
                switch newgrid[next] {
                case empty:
                    permEmpty++
                case occupied:
                    permOccupied++
                case floor:
                    break
                }
            }
            break
        }
    }
    return
}

// determine stable grid without simulating all frames
func stabilize(g grid, n int, direct bool) int {
    newgrid := grid{}
    newlyadded := grid{}
    for k,v := range g {
        if v == floor {
            newgrid[k] = floor
            continue
        }
        empty, _, _ := inView(g, grid{}, k, direct)
        if empty > 8 - n {
            newgrid[k] = occupied
            newlyadded[k] = occupied
        }
    }
    toCheck := newToCheck(g, newlyadded, newgrid, direct)
    for len(toCheck) > 0 {
        toAdd := grid{}
        for k, _ := range toCheck {
            emp, occ, _ := inView(g, newgrid, k, direct)
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
        toCheck = newToCheck(g, toAdd, newgrid, direct)
    }
    return sumOccupied(newgrid)
}

func newToCheck(g, newlyadded, newgrid grid, direct bool) map[coord]struct{} {
    toCheck := map[coord]struct{}{}
    for k, _ := range newlyadded {
        _, _, nns := inView(g, nil, k, direct)
        for _, n := range nns {
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

    // runs 3x as fast as the above
    t1 := stabilize(m, 4, true)
    lib.WritePart1("%d", t1)

    t2 := stabilize(m, 5, false)
    lib.WritePart2("%d", t2)
}
