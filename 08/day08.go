package main

import (
    "fmt"
    "github.com/deosjr/adventofcode2020/lib"
)

type instr struct {
    typ string
    value int
}

func exec(ins instr) (int, int) {
    switch ins.typ {
    case "nop":
        return 1,0
    case "acc":
        return 1,ins.value
    case "jmp":
        return ins.value,0
    default:
        panic("unexp")
    }
}

// bool is true if terminated and false if loop
func run(program map[int]instr) (int, bool) {
    ptr := 0
    acc := 0
    visited := map[int]struct{}{}
    for {
        ins, ok := program[ptr]
        if !ok {
            // terminated
            return acc, true
        }
        nptr, nacc := exec(ins)
        ptr += nptr
        acc += nacc
        if _, ok := visited[ptr]; ok {
            // loop
            return acc, false
        }
        visited[ptr] = struct{}{}
    }
}

func main() {
    m := map[int]instr{}
    i := 0
    readfunc := func(line string) {
        var typ string
        var value int
        _, err := fmt.Sscanf(line, "%s %d", &typ, &value)
        if err != nil {
            panic(err)
        }
        m[i] = instr{typ, value}
        i++
    }
    lib.ReadFileByLine(8, readfunc)

    p1, _ := run(m)
    lib.WritePart1("%d", p1)

    var p2 int
    for i:=0; i<len(m); i++ {
        newm := map[int]instr{}
        ins := m[i]
        if ins.typ == "acc" {
            continue
        }
        if ins.typ == "nop" {
            ins.typ = "jmp"
        } else {
            ins.typ = "nop"
        }
        newm[i] = ins
        for k,v := range m {
            if k == i {
                continue
            }
            newm[k] = v
        }
        acc, terminated := run(newm)
        if terminated {
            p2 = acc
            break
        }
    }

    lib.WritePart2("%d", p2)
}
