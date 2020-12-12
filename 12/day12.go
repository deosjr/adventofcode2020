package main

import (
    "fmt"
    "math"

    "github.com/deosjr/adventofcode2020/lib"
)

type instr struct {
    action rune
    value int
}

type coord struct {
    x, y int
}

func turnLeft(heading coord, degrees int) coord {
    turns := degrees / 90
    for i:=0; i<turns; i++ {
        heading = coord{heading.y * -1, heading.x}
    }
    return heading
}

func turnRight(heading coord, degrees int) coord {
    turns := degrees / 90
    for i:=0; i<turns; i++ {
        heading = coord{heading.y, heading.x * -1}
    }
    return heading
}

func main() {
    list := []instr{}
    readfunc := func(line string) {
        var action rune
        var value int
        _, err := fmt.Sscanf(line, "%c%d", &action, &value)
        if err != nil {
            panic(err)
        }
        parsed := instr{action, value}
        list = append(list, parsed)
    }
    lib.ReadFileByLine(12, readfunc)

    heading := coord{1, 0}
    pos := coord{0, 0}
    for _, ins := range list {
        switch ins.action {
        case 'N':
            pos = coord{pos.x, pos.y+ins.value}
        case 'S':
            pos = coord{pos.x, pos.y-ins.value}
        case 'E':
            pos = coord{pos.x+ins.value, pos.y}
        case 'W':
            pos = coord{pos.x-ins.value, pos.y}
        case 'L':
            heading = turnLeft(heading, ins.value)
        case 'R':
            heading = turnRight(heading, ins.value)
        case 'F':
            dxdy := coord{heading.x * ins.value, heading.y * ins.value}
            pos = coord{pos.x + dxdy.x, pos.y + dxdy.y}
        }
    }
    p1 := int(math.Abs(float64(pos.x)) + math.Abs(float64(pos.y)))
    lib.WritePart1("%d", p1)

    pos = coord{0, 0}
    waypoint := coord{10, 1}
    for _, ins := range list {
        switch ins.action {
        case 'N':
            waypoint = coord{waypoint.x, waypoint.y+ins.value}
        case 'S':
            waypoint = coord{waypoint.x, waypoint.y-ins.value}
        case 'E':
            waypoint = coord{waypoint.x+ins.value, waypoint.y}
        case 'W':
            waypoint = coord{waypoint.x-ins.value, waypoint.y}
        case 'L':
            waypoint = turnLeft(waypoint, ins.value)
        case 'R':
            waypoint = turnRight(waypoint, ins.value)
        case 'F':
            dxdy := coord{waypoint.x * ins.value, waypoint.y * ins.value}
            pos = coord{pos.x + dxdy.x, pos.y + dxdy.y}
        }
    }
    p2 := int(math.Abs(float64(pos.x)) + math.Abs(float64(pos.y)))
    lib.WritePart2("%d", p2)
}
