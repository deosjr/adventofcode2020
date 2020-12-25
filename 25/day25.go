package main

import (
    "math/big"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

var mod int64 = 20201227

func transform(subject *big.Int, loopsize *big.Int) *big.Int {
    result := big.NewInt(0)
    result.Exp(subject, loopsize, big.NewInt(mod))
    return result
}

func reverseTransform(key int64, modinverse int64) int64 {
    var loop int64
    for {
        loop++
        key = (key * modinverse) % mod
        if key == 1 {
            break
        }
    }
    return loop
}

func main() {
    input := lib.ReadFile(25)
    split := strings.Split(input, "\n")
    key1 := lib.MustParseInt(split[0])
    key2 := lib.MustParseInt(split[1])

    // by fermat's little theorem
    inverse := big.NewInt(0)
    inverse.Exp(big.NewInt(7), big.NewInt(mod - 2), big.NewInt(mod))

    key1rev := reverseTransform(key1, inverse.Int64())
    p1 := transform(big.NewInt(key2), big.NewInt(key1rev))
    lib.WritePart1("%d", p1)

    lib.WritePart2("%s", "Congratulations!")
}
