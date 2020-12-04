package main

import (
    "regexp"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

var (
    fourdigits = regexp.MustCompile(`^[0-9]{4}$`)
    haircolor = regexp.MustCompile(`^#[0-9a-f]{6}$`)
    eyecolor = regexp.MustCompile(`^(amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)$`)
    passportID = regexp.MustCompile(`^[0-9]{9}$`)

    keys = []string{"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"}
)

func stringNumInRange(str string, min, max int64) bool {
    n := lib.MustParseInt(str)
    return n >= min && n <= max
}

func checkValid(m map[string]string) bool {
    for _, key := range keys {
        v := m[key]
        switch key {
        case "byr":
            if !fourdigits.MatchString(v) || !stringNumInRange(v, 1920, 2002) {
                return false
            }
        case "iyr":
            if !fourdigits.MatchString(v) || !stringNumInRange(v, 2010, 2020) {
                return false
            }
        case "eyr":
            if !fourdigits.MatchString(v) || !stringNumInRange(v, 2020, 2030) {
                return false
            }
        case "hgt":
            numstr, unit := v[:len(v)-2], v[len(v)-2:]
            switch unit {
            case "cm":
                if !stringNumInRange(numstr, 150, 193) {
                    return false
                }
            case "in":
                if !stringNumInRange(numstr, 59, 76) {
                    return false
                }
            default:
                return false
            }
        case "hcl":
            if !haircolor.MatchString(v) {
                return false
            }
        case "ecl":
            if !eyecolor.MatchString(v) {
                return false
            }
        case "pid":
            if !passportID.MatchString(v) {
                return false
            }
        }
    }
    return true
}

func main() {
    input := lib.ReadFile(4)
    rawpassports := strings.Split(input, "\n\n")
    validP1, validP2 := 0, 0
    for _, rawp := range rawpassports {
        lines := strings.Split(rawp, "\n")
        m := map[string]string{}
        for _, line := range lines {
            split := strings.Split(line, " ")
            for _, str := range split {
                if str == "" {
                    continue
                }
                kv := strings.Split(str, ":")
                m[kv[0]] = kv[1]
            }
        }
        _, ok := m["cid"]
        if (len(m) == 8) || len(m) == 7 && !ok {
            validP1++
            if checkValid(m) {
                validP2++
            }
        }
    }

    lib.WritePart1("%d", validP1)

    lib.WritePart2("%d", validP2)
}
