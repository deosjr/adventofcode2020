package main

import (
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

// returns true if P1 wins, false for P2
func playp1(deck1, deck2 []uint8) int64 {
    d1 := make([]uint8, len(deck1))
    copy(d1, deck1)
    d2 := make([]uint8, len(deck2))
    copy(d2, deck2)

    var c1, c2 uint8
    for len(d1) > 0 && len(d2) > 0 {
        c1, d1 = d1[0], d1[1:]
        c2, d2 = d2[0], d2[1:]
        if c1 > c2 {
            d1 = append(d1, c1, c2)
            continue
        }
        d2 = append(d2, c2, c1)
    }
    if len(d1) > 0 {
        return hash(d1)
    }
    return hash(d2)
}

func hash(deck []uint8) int64 {
    var sum int64
    for i:=1; i<=len(deck); i++ {
        sum += int64(deck[len(deck)-i]) * int64(i)
    }
    return sum
}

type state struct {
    hash1, hash2 int64
}

func makehash(d1, d2 []uint8) state {
    return state{hash(d1), hash(d2)}
}

type result struct {
    deck1, deck2 []uint8
    p1wins bool
}

func playp2(deck1, deck2 []uint8) result {
    startstate := makehash(deck1, deck2)
    knownstates := map[state]struct{}{startstate: struct{}{}}

    d1 := make([]uint8, len(deck1))
    copy(d1, deck1)
    d2 := make([]uint8, len(deck2))
    copy(d2, deck2)

    var c1, c2 uint8
    for len(d1) > 0 && len(d2) > 0 {
        c1, d1 = d1[0], d1[1:]
        c2, d2 = d2[0], d2[1:]

        if uint8(len(d1)) >= c1 && uint8(len(d2)) >= c2 {
            rec := playp2(d1[:c1], d2[:c2])
            if rec.p1wins {
                d1 = append(d1, c1, c2)
            } else {
                d2 = append(d2, c2, c1)
            }
        } else {
            if c1 > c2 {
                d1 = append(d1, c1, c2)
            } else {
                d2 = append(d2, c2, c1)
            }
        }

        s := makehash(d1, d2)
        if _, ok := knownstates[s]; ok {
            return result{d1, d2, true}
        }
        knownstates[s] = struct{}{}
    }
    p1wins := len(d1)>0
    return result{d1, d2, p1wins}
}

func main() {
    var deck1, deck2 []uint8
    input := lib.ReadFile(22)
    mainsplit := strings.Split(input, "\n\n")

    for _, str := range strings.Split(mainsplit[0], "\n")[1:] {
        if str == "" { continue }
        deck1 = append(deck1, uint8(lib.MustParseInt(str)))
    }

    for _, str := range strings.Split(mainsplit[1], "\n")[1:] {
        if str == "" { continue }
        deck2 = append(deck2, uint8(lib.MustParseInt(str)))
    }

    p1 := playp1(deck1, deck2)
    lib.WritePart1("%d", p1)

    r := playp2(deck1, deck2)
    var p2 int64
    if r.p1wins {
        p2 = hash(r.deck1)
    } else {
        p2 = hash(r.deck2)
    }
    lib.WritePart2("%d", p2)
}
