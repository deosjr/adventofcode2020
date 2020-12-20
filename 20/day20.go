package main

import (
    "math/bits"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

type tile struct {
    ID int64
    image []string
    hashes []uint16
}

func newTile(id int64, img []string) tile {
    h := borderHashes(img)
    return tile{ID:id, image:img, hashes:h}
}

func (t tile) hits(m map[uint16][]int64) int {
    hit := 0
    for _, b := range t.hashes {
        if ids, ok := m[b]; ok {
            if !onlyContains(ids, t.ID) {
                hit++
                continue
            }
        }
    }
    return hit
}

func onlyContains(ids []int64, id int64) bool {
    return len(ids) == 1 && ids[0] == id
}

// returns NESW order hash of borders
// reading for each is left to right _IF_ that border were north!
func borderHashes(image []string) []uint16 {
    borders := make([]uint16, 4)
    north := image[0]
    borders[0] = borderToBinary(north)
    east := ""
    for _, s := range image {
        east = east + string(s[9])
    }
    borders[1] = borderToBinary(east)
    south := ""
    west := ""
    for i:=9; i>=0; i-- {
        south = south + string(image[9][i])
        west = west + string(image[i][0])
    }
    borders[2] = borderToBinary(south)
    borders[3] = borderToBinary(west)
    return borders
}

func borderToBinary(str string) uint16 {
    str = strings.Replace(str, ".", "0", -1)
    str = strings.Replace(str, "#", "1", -1)
    n, err := strconv.ParseInt(str, 2, 64)
    if err != nil {
        panic(err)
    }
    return uint16(n)
}

func main() {
    input := lib.ReadFile(20)
    tilesRaw := strings.Split(strings.TrimSpace(input), "\n\n")
    tiles := make([]tile, len(tilesRaw))
    for i, tr := range tilesRaw {
        split := strings.Split(tr, "\n")
        n := lib.MustParseInt(split[0][5:9])
        tiles[i] = newTile(n, split[1:])
    }
    // len(tiles) = 144, so 12x12 picture. each image is 10x10
    m := map[uint16][]int64{}
    for _, t := range tiles {
        for _, b := range t.hashes {
            m[b] = append(m[b], t.ID)
            revb := bits.Reverse16(b) >> 6
            m[revb] = append(m[revb], t.ID)
        }
    }

    var p1 int64 = 1
    for _, t := range tiles {
        hit := t.hits(m)
        if hit == 2 {
            p1 *= t.ID
        }
    }

    lib.WritePart1("%d", p1)

    //lib.WritePart2("%d", p2)
}
