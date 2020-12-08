package main

import (
    "fmt"
    "github.com/deosjr/adventofcode2020/lib"
)

type instr struct {
    typ string
    value int
}

type intset map[int]struct{}
type program map[int]instr

func exec(ins instr) (nptr, nacc int) {
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

func run(prog program) (int, bool, intset) {
    ptr := 0
    acc := 0
    visited := intset{}
    for {
        ins, ok := prog[ptr]
        if !ok {
            // terminated
            return acc, true, visited
        }
        nptr, nacc := exec(ins)
        ptr += nptr
        acc += nacc
        if _, ok := visited[ptr]; ok {
            // loop
            return acc, false, visited
        }
        visited[ptr] = struct{}{}
    }
}

func main() {
    m := program{}
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

    p1, _, visited := run(m)
    lib.WritePart1("%d", p1)

    // original part2: brute force through all the mutations and run
    // new part2: find the single instruction to flip, then run that

    // build a reverse lookup for next ptr values for each instr
    // if we jmp outside the program we 'win'
    // walking backwards, every instr is winning until the first 'real' jmp

    // from nextptr to ptrs; to revisit to update winning
    ptrs := map[int][]int{}
    winning := intset{}
    jmpseen := false
    for i:=len(m)-1;i>=0;i-- {
        ins := m[i]
        // only count jmp when it jumps to a valid instruction
        if ins.typ == "jmp" && i+ins.value<len(m) {
            jmpseen = true
        }
        if !jmpseen {
            winning[i] = struct{}{}
            continue
        }
        switch ins.typ {
        case "acc","nop":
            ptrs[i+1] = append(ptrs[i+1], i)
        case "jmp":
            next := i+ins.value
            if next >= len(m) {
                winning[i] = struct{}{}
                continue
            }
            ptrs[next] = append(ptrs[next], i)
        }
    }

    // keep updating the set of ptrs that lead to a 'win'
    // start from winning states and add all the previous ones, repeat
    newlyAdded := winning
    for len(newlyAdded) > 0 {
        newnew := intset{}
        for w, _ := range newlyAdded {
            list, ok := ptrs[w]
            if !ok {
                continue
            }
            for _, v := range list {
                winning[v] = struct{}{}
                newnew[v] = struct{}{}
            }
        }
        newlyAdded = newnew
    }

    // valid candidates to repair are those that would lead to a 'win'
    // and are actually visited in the original run of the program (p1)
    // originally kept a set of candidates but we are guaranteed to find only 1
    var instrToRepair int
    for i:=0; i<len(m); i++ {
        if _, ok := winning[i]; ok {
            continue
        }
        if _, ok := visited[i]; !ok {
            continue
        }
        ins := m[i]
        var nptr int
        switch ins.typ {
        case "acc":
            continue
        case "nop":
            nptr = i+ins.value
        case "jmp":
            nptr = i+1
        }
        if _, ok := winning[nptr]; ok {
            instrToRepair = i
            break
        }
    }

    // now repair the only candidate and run the program again
    var p2 int
    ins := m[instrToRepair]
    if ins.typ == "nop" {
        ins.typ = "jmp"
    } else {
        ins.typ = "nop"
    }
    m[instrToRepair] = ins
    acc, _, _ := run(m)
    p2 = acc

    lib.WritePart2("%d", p2)
}
