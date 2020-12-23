package main

import (
    "fmt"

    "github.com/deosjr/adventofcode2020/lib"
)

type node struct {
    next *node
    label int64
}

func move(m map[int64]*node, current *node) *node {
    a := current.next
    b := a.next
    c := b.next
    newcurrent := c.next
    destination := findDestination(m, current.label, a.label, b.label, c.label)
    olddestnext := destination.next

    current.next = newcurrent
    destination.next = a
    c.next = olddestnext
    return newcurrent
}

func findDestination(m map[int64]*node, current, a, b, c int64) *node {
    toFind := current - 1
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    if toFind < 1 {
        toFind =  int64(len(m))
    }
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    if a == toFind || b == toFind || c == toFind {
        toFind -= 1
    }
    return m[toFind]
}

func main() {
    cups := []int64{}
    for _, c := range lib.ReadFile(23) {
        if c == '\n' {
            break
        }
        cups = append(cups, lib.MustParseInt(string(c)))
    }

    m := map[int64]*node{}
    for _, v := range cups {
        m[v] = &node{label:v}
    }
    for i:=0; i<len(cups)-1; i++ {
        m[cups[i]].next = m[cups[i+1]]
    }
    m[cups[len(cups)-1]].next = m[cups[0]]

    current := m[cups[0]]
    for i:=0; i<100; i++ {
        current = move(m, current)
    }

    p1 := ""
    next := m[1].next
    for {
        if next.label == 1 {
            break
        }
        p1 += fmt.Sprintf("%d", next.label)
        next = next.next
    }
    lib.WritePart1("%s", p1)

    newlen := 1_000_000
    m2 := map[int64]*node{}
    for _, v := range cups {
        m2[v] = &node{label:v}
    }
    for i:=len(cups)+1; i<=newlen; i++ {
        m2[int64(i)] = &node{label: int64(i)}
    }
    for i:=0; i<len(cups)-1; i++ {
        m2[cups[i]].next = m2[cups[i+1]]
    }
    m2[cups[len(cups)-1]].next = m2[int64(len(cups)+1)]
    for i:=len(cups)+1; i<newlen; i++ {
        m2[int64(i)].next = m2[int64(i+1)]
    }
    m2[int64(newlen)].next = m2[cups[0]]

    current = m2[cups[0]]
    for i:=0; i<10_000_000; i++ {
        current = move(m2, current)
    }

    one := m2[1]
    p2 := one.next.label * one.next.next.label
    lib.WritePart2("%d", p2)
}
