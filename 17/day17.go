package main

import (
    "github.com/deosjr/adventofcode2020/lib"
)

type Coord interface {
    Neighbours() []Coord
}

type coord3d struct {
    x, y, z int
}

type coord4d struct {
    x, y, z, w int
}

var cache3d = map[coord3d][]Coord{}

func (c coord3d) Neighbours() []Coord {
    if v, ok := cache3d[c]; ok {
        return v
    }
    n := []Coord{}
    for x:=c.x-1;x<=c.x+1;x++ {
        for y:=c.y-1;y<=c.y+1;y++ {
            for z:=c.z-1;z<=c.z+1;z++ {
                if x==c.x && y==c.y && z==c.z {
                    continue
                }
                n = append(n, coord3d{x,y,z})
            }
        }
    }
    cache3d[c] = n
    return n
}

var cache4d = map[coord4d][]Coord{}

func (c coord4d) Neighbours() []Coord {
    if v, ok := cache4d[c]; ok {
        return v
    }
    n := []Coord{}
    for x:=c.x-1;x<=c.x+1;x++ {
        for y:=c.y-1;y<=c.y+1;y++ {
            for z:=c.z-1;z<=c.z+1;z++ {
                for w:=c.w-1;w<=c.w+1;w++ {
                    if x==c.x && y==c.y && z==c.z && w==c.w {
                        continue
                    }
                    n = append(n, coord4d{x,y,z,w})
                }
            }
        }
    }
    cache4d[c] = n
    return n
}

type CoordSet interface {
    Add(Coord)
    Contains(Coord) bool
    EmptyCopy() CoordSet
    Size() int
    Elements() []Coord
}

type coordset3d map[coord3d]struct{}

func (s coordset3d) Add(c Coord) {
    s[c.(coord3d)] = struct{}{}
}

func (s coordset3d) Contains(c Coord) bool {
    cc, ok := c.(coord3d)
    if !ok {
        return false
    }
    _, ok = s[cc]
    return ok
}

func (coordset3d) EmptyCopy() CoordSet {
    return coordset3d{}
}

func (c coordset3d) Size() int {
    return len(c)
}

func (c coordset3d) Elements() []Coord {
    elems := []Coord{}
    for k, _ := range c {
        elems = append(elems, k)
    }
    return elems
}

type coordset4d map[coord4d]struct{}

func (s coordset4d) Add(c Coord) {
    s[c.(coord4d)] = struct{}{}
}

func (s coordset4d) Contains(c Coord) bool {
    cc, ok := c.(coord4d)
    if !ok {
        return false
    }
    _, ok = s[cc]
    return ok
}

func (coordset4d) EmptyCopy() CoordSet {
    return coordset4d{}
}

func (c coordset4d) Size() int {
    return len(c)
}

func (c coordset4d) Elements() []Coord {
    elems := []Coord{}
    for k, _ := range c {
        elems = append(elems, k)
    }
    return elems
}

func sumNeighbours(m CoordSet, c Coord) (sum int) {
    for _, n := range c.Neighbours() {
        if m.Contains(n) {
            sum++
        }
    }
    return sum
}

func addToCheck(toCheck CoordSet, c Coord) {
    toCheck.Add(c)
    for _, n := range c.Neighbours() {
        toCheck.Add(n)
    }
}

func iterate(m, toCheck CoordSet) (CoordSet, CoordSet) {
    newm := m.EmptyCopy()
    newToCheck := toCheck.EmptyCopy()
    for _, c := range toCheck.Elements() {
        sum := sumNeighbours(m, c)
        if m.Contains(c) {
            if sum == 2 || sum == 3 {
                newm.Add(c)
                addToCheck(newToCheck, c)
            }
        } else {
            if sum == 3 {
                newm.Add(c)
                addToCheck(newToCheck, c)
            }
        }
    }
    return newm, newToCheck
}

func main() {
    var m1 CoordSet = coordset3d{}
    var m2 CoordSet = coordset4d{}
    y := 0
    readfunc := func(line string) {
        for x, c := range line {
            if c != '#' {
                continue
            }
            m1.Add(coord3d{x:x, y:y, z:0})
            m2.Add(coord4d{x:x, y:y, z:0, w:0})
        }
        y++
    }
    lib.ReadFileByLine(17, readfunc)

    var toCheck1 CoordSet = coordset3d{}
    for _, c := range m1.Elements() {
        addToCheck(toCheck1, c)
    }
    for i:=0; i<6; i++ {
        m1, toCheck1 = iterate(m1, toCheck1)
    }
    lib.WritePart1("%d", m1.Size())

    var toCheck2 CoordSet = coordset4d{}
    for _, c := range m2.Elements() {
        addToCheck(toCheck2, c)
    }
    for i:=0; i<6; i++ {
        m2, toCheck2 = iterate(m2, toCheck2)
    }
    lib.WritePart2("%d", m2.Size())
}
