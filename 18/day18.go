package main

import (
    "github.com/deosjr/adventofcode2020/lib"
)

type node interface{
    ValueP1() int64
    ValueP2() int64
}

type operator rune

type expression struct {
    nodes []node
    ops   []operator
}

func newExpression(first node) expression {
    return expression{nodes: []node{first}, ops: []operator{}}
}

func (e expression) ValueP1() int64 {
    value := e.nodes[0].ValueP1()
    for i, op := range e.ops {
        switch op {
        case '+':
            value += e.nodes[i+1].ValueP1()
        case '*':
            value *= e.nodes[i+1].ValueP1()
        }
    }
    return value
}

func (e expression) ValueP2() int64 {
    additions := []int64{}
    value := e.nodes[0].ValueP2()
    for i, op := range e.ops {
        switch op {
        case '+':
            value += e.nodes[i+1].ValueP2()
        case '*':
            additions = append(additions, value)
            value = e.nodes[i+1].ValueP2()
        }
    }
    for _, n := range additions {
        value *= n
    }
    return value
}

type argument struct {
    n int64
}

func (a argument) ValueP1() int64 {
    return a.n
}

func (a argument) ValueP2() int64 {
    return a.n
}

func parseExpression(str string, depth int) (expression, string) {
    left, rem := parseExpressionOrInt(str, depth)
    expr := newExpression(left)
    return parseOpAndRight(rem, depth, expr)
}

func parseOpAndRight(str string, depth int, expr expression) (expression, string) {
    op, rem1 := parseOperator(str)
    expr.ops = append(expr.ops, op)
    right, rem2 := parseExpressionOrInt(rem1, depth)
    expr.nodes = append(expr.nodes, right)
    if rem2 == "" && depth == 0 {
        return expr, ""
    }
    if rem2[0] == ')' {
        return expr, rem2[1:]
    }
    return parseOpAndRight(rem2, depth, expr)
}

func parseExpressionOrInt(str string, depth int) (node, string) {
    if str[0] == '(' {
        return parseExpression(str[1:], depth+1)
    }
    n := lib.MustParseInt(string(str[0]))
    return argument{n}, str[1:]
}

func parseOperator(str string) (operator, string) {
    op := operator(str[1])
    return op, str[3:]
}

func main() {
    exprs := []expression{}
    readFunc := func(line string) {
        e, _ := parseExpression(line, 0)
        exprs = append(exprs, e)
    }
    lib.ReadFileByLine(18, readFunc)

    var p1 int64
    for _, e := range exprs {
        p1 += e.ValueP1()
    }
    lib.WritePart1("%d", p1)

    var p2 int64
    for _, e := range exprs {
        p2 += e.ValueP2()
    }
    lib.WritePart2("%d", p2)
}
