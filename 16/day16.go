package main

import (
    "fmt"
    "strconv"
    "strings"

    "github.com/deosjr/adventofcode2020/lib"
)

type ticket []int

type field struct {
    name string
    min1, max1, min2, max2 int
}

func (f field) inRange(value int) bool {
    return (f.min1 <= value && value <= f.max1) || (f.min2 <= value && value <= f.max2)
}

func (f field) allInRange(values []int) bool {
    for _, v := range values {
        if !f.inRange(v) {
            return false
        }
    }
    return true
}

func parseFields(str string) []field {
    fields := []field{}
    for _, line := range strings.Split(str, "\n") {
        split := strings.Split(line, ":")
        name := split[0]
        var min1, max1, min2, max2 int
        fmt.Sscanf(split[1], " %d-%d or %d-%d", &min1, &max1, &min2, &max2)
        fields = append(fields, field{name, min1, max1, min2, max2})
    }
    return fields
}

func parseTicket(str string) ticket {
    t := []int{}
    for _, s := range strings.Split(str, ",") {
        n, _ := strconv.Atoi(s)
        t = append(t, n)
    }
    return t
}

func parseTickets(str string) []ticket {
    tickets := []ticket{}
    for _, line := range strings.Split(str, "\n")[1:] {
        if len(line) == 0 {
            continue
        }
        tickets = append(tickets, parseTicket(line))
    }
    return tickets
}

func findInvalid(fields []field, tickets []ticket) (sum int) {
    for _, t := range tickets {
        n, _ := isTicketInvalid(fields, t)
        sum += n
    }
    return
}

func isTicketInvalid(fields []field, t ticket) (sum int, invalid bool) {
Loop:
    for _, v := range t {
        for _, f := range fields {
            if f.inRange(v) {
                continue Loop
            }
        }
        invalid = true
        sum += v
    }
    return
}

func findDepartureFields(fields []field, yt ticket, tickets []ticket) int {
    validTickets := []ticket{}
    for _, t := range tickets {
        if _, ok := isTicketInvalid(fields, t); ok {
            continue
        }
        validTickets = append(validTickets, t)
    }

    // gather all the known ticket values by column
    columns := make([][]int, len(yt))
    for i, v := range yt {
        columns[i] = []int{v}
    }
    for _, t := range validTickets {
        for i, v := range t {
            columns[i] = append(columns[i], v)
        }
    }

    // per column, find all fields for which all values are in range
    configs := []map[int]struct{}{}
    for _, values := range columns {
        validfields := map[int]struct{}{}
        for i, f := range fields {
            if f.allInRange(values) {
                validfields[i] = struct{}{}
            }
        }
        configs = append(configs, validfields)
    }

    // find all columns that can only fit one field, their mapping is now known
    // delete that field from the rest of configs and repeat until all are found
    m := map[int]int{}
    for len(m) < len(yt) {
        found := map[int]struct{}{}
        for i, cfg := range configs {
            if len(cfg) == 1 {
                for k,_ := range cfg {
                    m[k] = i
                    found[k] = struct{}{}
                }
            }
        }
        for _, cfg := range configs {
            for k, _ := range found {
                delete(cfg, k)
            }
        }
    }

    // departure fields are the first 6 fields in your ticket
    ans := 1
    for i:=0; i<6; i++ {
        ans *= yt[m[i]]
    }
    return ans
}

func main() {
    input := lib.ReadFile(16)
    split := strings.Split(input, "\n\n")
    fields := parseFields(split[0])
    ticketInput := strings.Split(split[1], "\n")[1]
    yourTicket := parseTicket(ticketInput)
    tickets := parseTickets(split[2])

    p1 := findInvalid(fields, tickets)
    lib.WritePart1("%d", p1)

    p2 := findDepartureFields(fields, yourTicket, tickets)
    lib.WritePart2("%d", p2)
}
