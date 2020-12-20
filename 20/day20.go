package main

import (
    "fmt"
    "math/bits"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

type coord struct {
    x, y int
}

type tile struct {
    ID int64
    image []string
    hashes []uint16
    // flipped=true if flipped vertically during placement
    // rotated in 0..3 incl, number of CLOCKWISE rotations
    flipped bool
    rotated uint8
    placed bool
}

func newTile(id int64, img []string) *tile {
    h := borderHashes(img)
    return &tile{ID:id, image:img, hashes:h}
}

func (t *tile) printline(line int) string {
    str := ""
    if t.flipped {
        switch t.rotated {
        case 0:
            for i:=9; i>=0; i-- {
                str += fmt.Sprintf("%c", t.image[line][i])
            }
        case 1:
            for i:=9; i>=0; i-- {
                str += fmt.Sprintf("%c", t.image[i][9-line])
            }
        case 2:
            for i:=0; i<10; i++ {
                str += fmt.Sprintf("%c", t.image[9-line][i])
            }
        case 3:
            for i:=0; i<10; i++ {
                str += fmt.Sprintf("%c", t.image[i][line])
            }
        }
        return str
    }
    switch t.rotated {
    case 0:
        return t.image[line]
    case 1:
        for i:=9; i>=0; i-- {
            str += fmt.Sprintf("%c", t.image[i][line])
        }
    case 2:
        for i:=9; i>=0; i-- {
            str += fmt.Sprintf("%c", t.image[9-line][i])
        }
    case 3:
        for i:=0; i<10; i++ {
            str += fmt.Sprintf("%c", t.image[i][9-line])
        }
    }
    return str
}

func (t *tile) hits(m map[uint16][]int64) int {
    num := 0
    for _, b := range t.hashes {
        if t.hit(m, b) {
            num++
            continue
        }
    }
    return num
}

func (t *tile) hit(m map[uint16][]int64, b uint16) bool {
    if ids, ok := m[b]; ok {
        if !onlyContains(ids, t.ID) {
            return true
        }
    }
    return false
}

func onlyContains(ids []int64, id int64) bool {
    return len(ids) == 1 && ids[0] == id
}

func (t *tile) rotate() {
    t.hashes = []uint16{t.hashes[3], t.hashes[0], t.hashes[1], t.hashes[2]}
    t.rotated = (t.rotated + 1) % 4
}

func (t *tile) flip() {
    t.hashes = []uint16{
        flipHash(t.hashes[0]),
        flipHash(t.hashes[3]),
        flipHash(t.hashes[2]),
        flipHash(t.hashes[1]),
    }
    t.flipped = !t.flipped
}

func flipHash(b uint16) uint16 {
    return bits.Reverse16(b) >> 6
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

// t is a corner piece. no flips, rotate until no hits at north/west
// first one we place so flips dont matter (rest will have to adjust)
func placeULHC(m map[uint16][]int64, t *tile) {
    for i:=0; i< 4; i++ {
        if !t.hit(m, t.hashes[0]) && !t.hit(m, t.hashes[3]) {
            t.placed = true
            return
        }
        t.rotate()
    }
}

func (t *tile) placeUntil(condition func(*tile)bool) {
    for i:=0; i< 4; i++ {
        if condition(t) {
            t.placed = true
            return
        }
        t.rotate()
    }
    t.flip()
    for i:=0; i< 4; i++ {
        if condition(t) {
            t.placed = true
            return
        }
        t.rotate()
    }
}

func placeTopEdge(t *tile, westvalue uint16) {
    t.placeUntil(func(t *tile) bool {
        return t.hashes[3] == flipHash(westvalue)
    })
}

func placeLeftEdge(t *tile, southvalue uint16) {
    t.placeUntil(func(t *tile) bool {
        return t.hashes[0] == flipHash(southvalue)
    })
}

func placeURHC(m map[uint16][]int64, t *tile, westvalue uint16) {
    t.placeUntil(func(t *tile) bool {
        return !t.hit(m, t.hashes[0]) && !t.hit(m, t.hashes[1]) && t.hashes[3] == flipHash(westvalue)
    })
}

func placeMiddle(t *tile, southvalue, eastvalue uint16) {
    t.placeUntil(func(t *tile) bool {
        return t.hashes[0] == flipHash(southvalue) && t.hashes[3] == flipHash(eastvalue)
    })
}

func main() {
    input := lib.ReadFile(20)
    tilesRaw := strings.Split(strings.TrimSpace(input), "\n\n")
    tiles := make([]*tile, len(tilesRaw))
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
            revb := flipHash(b)
            m[revb] = append(m[revb], t.ID)
        }
    }

    corners := map[int64]*tile{}
    // edges can have 4 hits, so merge with mid pieces
    rest := map[int64]*tile{}
    for _, t := range tiles {
        switch t.hits(m) {
        case 2:
            corners[t.ID] = t
        case 3:
            rest[t.ID] = t
        case 4:
            rest[t.ID] = t
        }
    }

    var p1 int64 = 1
    for cid, _ := range corners {
        p1 *= cid
    }
    lib.WritePart1("%d", p1)

    // prints 40: expected 44. 4 collisions!
    //fmt.Println(len(edges))
    size := 12

    // try all corners; easier than rotating image at then end :P
    for _, ulhc := range corners {
    for _, tile := range tiles {
        tile.placed = false
    }

    // place ulhc
    grid := map[coord]*tile{}
    grid[coord{0,0}] = ulhc
    placeULHC(m, ulhc)

    // place top edge
    for x:=1; x<size-1; x++ {
        lastEast := grid[coord{x-1, 0}].hashes[1]
        matching := m[lastEast]
        for _, id := range matching {
            t, ok := rest[id]
            if !ok {
                continue
            }
            if t.placed {
                continue
            }
            placeTopEdge(t, lastEast)
            grid[coord{x,0}] = t
            break
        }
    }

    // place urhc
    lastEast := grid[coord{size-2,0}].hashes[1]
    matching := m[lastEast]
    for _, id := range matching {
        t, ok := corners[id]
        if !ok {
            continue
        }
        if t.placed {
            continue
        }
        placeURHC(m, t, lastEast)
        grid[coord{size-1,0}] = t
    }

    for y:=1; y<size-1; y++ {
        // place left edge
        lastSouth := grid[coord{0,y-1}].hashes[2]
        matching := m[lastSouth]
        for _, id := range matching {
            t, ok := rest[id]
            if !ok {
                continue
            }
            if t.placed {
                continue
            }
            placeLeftEdge(t, lastSouth)
            grid[coord{0,y}] = t
            break
        }
        // place middle pieces
        for x:=1; x<size-1; x++ {
            lastSouth := grid[coord{x,y-1}].hashes[2]
            lastEast := grid[coord{x-1,y}].hashes[1]
            matchSouth := m[lastSouth]
            matchEast := m[lastEast]
            Loop:
            for _, ids := range matchSouth {
                for _, ide := range matchEast {
                    if ids != ide {
                        continue
                    }
                    t, ok := rest[ids]
                    if !ok {
                        continue
                    }
                    if t.placed {
                        continue
                    }
                    placeMiddle(t, lastSouth, lastEast)
                    grid[coord{x,y}] = t
                    break Loop
                }
            }
        }
        // place right edge
        lastSouth = grid[coord{size-1,y-1}].hashes[2]
        matching = m[lastSouth]
        for _, id := range matching {
            t, ok := rest[id]
            if !ok {
                continue
            }
            if t.placed {
                continue
            }
            placeLeftEdge(t, lastSouth)
            grid[coord{size-1,y}] = t
            break
        }
    }

    // place llhc
    lastSouth := grid[coord{0,size-2}].hashes[2]
    matching = m[lastSouth]
    for _, id := range matching {
        t, ok := corners[id]
        if !ok {
            continue
        }
        if t.placed {
            continue
        }
        placeLeftEdge(t, lastSouth)
        grid[coord{0,size-1}] = t
    }
    // place bottom edge
    for x:=1; x<size-1; x++ {
        lastSouth := grid[coord{x, size-2}].hashes[2]
        matching := m[lastSouth]
        for _, id := range matching {
            t, ok := rest[id]
            if !ok {
                continue
            }
            if t.placed {
                continue
            }
            placeLeftEdge(t, lastSouth)
            grid[coord{x,size-1}] = t
            break
        }
    }

    // place lrhc
    lastSouth = grid[coord{size-1,size-2}].hashes[2]
    matching = m[lastSouth]
    for _, id := range matching {
        t, ok := corners[id]
        if !ok {
            continue
        }
        if t.placed {
            continue
        }
        placeLeftEdge(t, lastSouth)
        grid[coord{size-1,size-1}] = t
    }

    actualImage := make([]string, size * 8)
    for y:=0; y<size; y++ {
        for line:=0; line<8; line++ {
            str := ""
            for x:=0; x<size; x++ {
                co := coord{x, y}
                str = str + grid[co].printline(line+1)[1:9]
            }
            actualImage[y*8 + line] = str
        }
    }

    n, smap := findSeamonsters(actualImage)
    if n > 0 {
        p2 := countRoughness(actualImage, smap)
        lib.WritePart2("%d", p2)
    }

    imgflipped := make([]string, len(actualImage))
    for i, line := range actualImage {
        str := ""
        for j:=0; j<len(line); j++ {
            str = str + string(line[len(line)-1-j])
        }
        imgflipped[i] = str
    }

    n, smap = findSeamonsters(imgflipped)
    if n > 0 {
        p2 := countRoughness(imgflipped, smap)
        lib.WritePart2("%d", p2)
    }
}

}

func findSeamonsters(img []string) (int, map[coord]struct{}) {
    seamonsters := 0
    seamonstermap := map[coord]struct{}{}
    // 0-19
    //                  #   18
    //#    ##    ##    ###  0,5,6,11,12,17,18,19
    // #  #  #  #  #  #     1,4,7,10,13,16
    for i, line := range img[:len(img)-2] {
    Seamonsters:
        for j:=0; j<len(line)-20; j++ {
            temp := []coord{}
            if line[j+18] != '#' {
                continue Seamonsters
            }
            temp = append(temp, coord{j+18, i})
            line1 := img[i+1]
            for _, k := range []int{0,5,6,11,12,17,18,19} {
                if line1[j+k] != '#' {
                    continue Seamonsters
                }
                temp = append(temp, coord{j+k, i+1})
            }
            line2 := img[i+2]
            for _, k := range []int{1,4,7,10,13,16} {
                if line2[j+k] != '#' {
                    continue Seamonsters
                }
                temp = append(temp, coord{j+k, i+2})
            }
            seamonsters++
            for _, c := range temp {
                seamonstermap[c] = struct{}{}
            }
        }
    }
    return seamonsters, seamonstermap
}


func countRoughness(img []string, smap map[coord]struct{}) int {
    sum := 0
    for y, line := range img {
        for x, c := range line {
            if _, ok := smap[coord{x,y}]; ok {
                continue
            }
            if c == '#' {
                sum++
            }
        }
    }
    return sum
}
