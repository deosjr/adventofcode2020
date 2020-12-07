package main

import (
    "strings"
    "github.com/deosjr/adventofcode2020/lib"
)

func recFind(containedBy map[string][]string, color string) map[string]struct{} {
    m := map[string]struct{}{}
    containers := containedBy[color]
    for _, c := range containers {
        subm := recFind(containedBy, c)
        m[c] = struct{}{}
        for k,v := range subm {
            m[k] = v
        }
    }
    return m
}

type container struct {
    num int64
    color string
}

func recCount(contains map[string][]container, color string) int64 {
    var sum int64
    containers := contains[color]
    for _, c := range containers {
        sum += c.num
        sum += c.num * recCount(contains, c.color)
    }
    return sum
}

func main() {
    contains := map[string][]container{}
    containedBy := map[string][]string{}
    readfunc := func(line string) {
        firstsplit := strings.Split(strings.TrimSpace(line), " bags contain ")
        color := firstsplit[0]
        content := firstsplit[1]
        if content == "no other bags." {
            return
        }
        split := strings.Split(content, ", ")
        for _, c := range split {
            trimmed := strings.TrimRight(c, "bags.")
            trimmed = strings.TrimSpace(trimmed)
            num := lib.MustParseInt(string(trimmed[0]))
            col := trimmed[2:]
            container := container{num:num, color:col}
            contains[color] = append(contains[color], container)
            containedBy[col] = append(containedBy[col], color)
        }
    }
    lib.ReadFileByLine(7, readfunc)

    p1 := recFind(containedBy, "shiny gold")
    lib.WritePart1("%d", len(p1))

    p2 := recCount(contains, "shiny gold")
    lib.WritePart2("%d", p2)
}
