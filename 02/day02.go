package main

import (
    "fmt"

    "github.com/deosjr/adventofcode2020/lib"
)

type pwd struct {
    min int64
    max int64
    letter rune
    password string
}

func main() {
    list := []pwd{}
    readfunc := func(line string) {
        var min, max int64
        var letter rune
        var password string
        _, err := fmt.Sscanf(line, "%d-%d %c: %s", &min, &max, &letter, &password)
        if err != nil {
            panic(err)
        }
        parsed := pwd{min, max, letter, password}
        list = append(list, parsed)
    }
    lib.ReadFileByLine(2, readfunc)

    p1 := 0
    for _, pwd := range list {
        var c int64
        for _, r := range pwd.password {
            if r == pwd.letter {
                c++
            }
        }
        if c >= pwd.min && c <= pwd.max {
            p1++
        }
    }
    lib.WritePart1("%d", p1)

    p2 := 0
    for _, pwd := range list {
        c := 0
        if rune(pwd.password[pwd.min-1]) == pwd.letter {
            c++
        }
        if rune(pwd.password[pwd.max-1]) == pwd.letter {
            c++
        }
        if c == 1 {
            p2++
        }
    }
    lib.WritePart2("%d", p2)
}
