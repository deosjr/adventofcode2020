package lib

import (
    "bufio"
    "fmt"
    "io/ioutil"
    "os"
)

// ReadFile returns the entire file as one big string
func ReadFile(day int) string {
    filename := fmt.Sprintf("%02d/day%02d.input", day, day)
    bytes, err := ioutil.ReadFile(filename)
    if err != nil {
        panic(err)
    }
    return string(bytes)
}

// ReadFileByLine takes a function fn, which updates a data structure
// for each line in the input file. fn has to typecheck datastruct
func ReadFileByLine(day int, fn func(string)) {
    filename := fmt.Sprintf("%02d/day%02d.input", day, day)
    f, err := os.Open(filename)
    if err != nil {
        panic(err)
    }
    scanner := bufio.NewScanner(f)
    for scanner.Scan() {
        fn(scanner.Text())
    }
}

func WritePart1(format string, values ...interface{}) {
    answer := "Part 1: " + format + "\n"
    fmt.Printf(answer, values...)
}

func WritePart2(format string, values ...interface{}) {
    answer := "Part 2: " + format + "\n"
    fmt.Printf(answer, values...)
}
