package main

import (
    "fmt"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

func main() {
    var mask string
    mem1 := map[int64]int64{}
    mem2 := map[int64]int64{}
    readfunc := func(line string) {
        ismask := strings.HasPrefix(line, "mask")
        if ismask {
            fmt.Sscanf(line, "mask = %s", &mask)
            return
        }
        var index, value int64
        fmt.Sscanf(line, "mem[%d] = %d", &index, &value)
        // part 1
        valuestring := strings.Replace(fmt.Sprintf("%36s", strconv.FormatInt(value, 2)), " ", "0", -1)
        str := ""
        for i, k := range mask {
            if k != 'X' {
                str += string(k)
                continue
            }
            s := valuestring[i]
            str += string(s)
        }
        v, err := strconv.ParseInt(str, 2, 64)
        if err != nil {
            panic(err)
        }
        mem1[index] = v

        // part2
        addressstring := strings.Replace(fmt.Sprintf("%36s", strconv.FormatInt(index, 2)), " ", "0", -1)
        strs := []string{""}
        newstrs := []string{}
        for i, k := range mask {
            switch k {
            case 'X':
                for _, str := range strs {
                    newstrs = append(newstrs, str + "0")
                }
                for _, str := range strs {
                    newstrs = append(newstrs, str + "1")
                }
            case '1':
                for _, str := range strs {
                    newstrs = append(newstrs, str + "1")
                }
            case '0':
                for _, str := range strs {
                    newstrs = append(newstrs, str + string(addressstring[i]))
                }
            }
            strs = []string{}
            for _, k := range newstrs {
                strs = append(strs, k)
            }
            newstrs = []string{}
        }
        for _, str := range strs {
            address, err := strconv.ParseInt(str, 2, 64)
            if err != nil {
                panic(err)
            }
            mem2[address] = value
        }
    }
    lib.ReadFileByLine(14, readfunc)

    var p1 int64
    for _, v := range mem1 {
        p1 += v
    }
    lib.WritePart1("%d", p1)

    var p2 int64
    for _, v := range mem2 {
        p2 += v
    }
    lib.WritePart2("%d", p2)
}
