package main

import (
    "regexp"

    "github.com/deosjr/adventofcode2020/lib"
)

// using cube coords
type coord struct {
    x,y,z int
}

func follow(str []string) coord {
    var x, y, z int
    for _, instr := range str {
        switch instr {
        case "e":
            x++
            y--
        case "se":
            z++
            y--
        case "sw":
            x--
            z++
        case "w":
            x--
            y++
        case "nw":
            y++
            z--
        case "ne":
            x++
            z--
        }
    }
    return coord{x,y,z}
}

func neighbours(c coord) []coord {
    return []coord{
        {c.x+1, c.y-1, c.z},
        {c.x, c.y-1, c.z+1},
        {c.x-1, c.y, c.z+1},
        {c.x-1, c.y+1, c.z},
        {c.x, c.y+1, c.z-1},
        {c.x+1, c.y, c.z-1},
    }
}

func flip(m map[coord]bool) map[coord]bool {
    newm := map[coord]bool{}
    for c, _ := range m {
        sum := sumneighbours(m, c)
        if sum == 1 || sum == 2 {
            newm[c] = true
        }
        for _, n := range neighbours(c) {
            if _, ok := m[n]; ok {
                continue
            }
            if sumneighbours(m, n) == 2 {
                newm[n] = true
            }
        }
    }
    return newm
}

func sumneighbours(m map[coord]bool, c coord) int {
    sum := 0
    for _, n := range neighbours(c) {
        if _, ok := m[n]; ok {
            sum++
        }
    }
    return sum
}

var parse = regexp.MustCompile("(e|se|sw|w|nw|ne)")

func main() {
    instructions := [][]string{}
    readfunc := func(line string) {
        parsed := parse.FindAllStringSubmatch(line, -1)
        instruction := make([]string, len(parsed))
        for i, s := range parsed {
            instruction[i] = s[0]
        }
        instructions = append(instructions, instruction)

    }
    lib.ReadFileByLine(24, readfunc)

    m := map[coord]bool{}
    for _, instr := range instructions {
        c := follow(instr)
        m[c] = !m[c]
    }

    for k, v := range m {
        if !v {
            delete(m, k)
        }
    }
    lib.WritePart1("%d", len(m))

    for i:=0; i<100; i++ {
        m = flip(m)
    }
    lib.WritePart2("%d", len(m))
}
