package main

import (
    "sort"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

type set map[string]struct{}
type setofcounts map[string]map[string]int
type setofsetlists map[string][]set

func main() {
    allergenset := setofsetlists{}
    ingredientset := set{}
    list := [][]string{}
    readfunc := func(line string) {
        mainsplit := strings.Split(line, " (contains ")
        ingredients := mainsplit[0]
        allergens := mainsplit[1][:len(mainsplit[1])-1]
        ingsplit := strings.Split(ingredients, " ")
        list = append(list, ingsplit)
        ingset := set{}
        for _, ing := range ingsplit {
            ingset[ing] = struct{}{}
            ingredientset[ing] = struct{}{}
        }
        for _, all := range strings.Split(allergens, ", ") {
            allergenset[all] = append(allergenset[all], ingset)
        }
    }
    lib.ReadFileByLine(21, readfunc)

    candidateset := setofcounts{}
    for allergen, setlist := range allergenset {
        candidateset[allergen] = map[string]int{}
        if len(setlist) == 1 {
            for k, _ := range setlist[0] {
                candidateset[allergen][k] = 1
            }
            continue
        }
        for _, set := range setlist {
            for ing, _ := range set {
                candidateset[allergen][ing] = candidateset[allergen][ing] + 1
            }
        }
        for k, v := range candidateset[allergen] {
            if v != len(setlist) {
                delete(candidateset[allergen], k)
            }
        }
    }

    impossible := set{}
    Loop:
    for ing, _ := range ingredientset {
        for _, s := range candidateset {
            for k, _ := range s {
                if k == ing {
                    continue Loop
                }
            }
        }
        impossible[ing] = struct{}{}
    }

    p1 := 0
    for _, inglist := range list {
        for _, ing := range inglist {
            if _, ok := impossible[ing]; ok {
                p1++
            }
        }
    }
    lib.WritePart1("%d", p1)

    keys := []string{}
    known := map[string]string{}
    used := map[string]struct{}{}
    for len(candidateset) > 0 {
        for k, v := range candidateset {
            if len(v) > 1 {
                continue
            }
            for kk, _ := range v {
                known[k] = kk
                keys = append(keys, k)
                used[kk] = struct{}{}
            }
            delete(candidateset, k)
        }
        for _, v := range candidateset {
            for kk, _ := range v {
                if _, ok := used[kk]; ok {
                    delete(v, kk)
                }
            }
        }
    }

    sort.Strings(keys)
    values := make([]string, len(keys))
    for i, k := range keys {
        values[i] = known[k]
    }
    p2 := strings.Join(values, ",")
    lib.WritePart2("%s", p2)
}
