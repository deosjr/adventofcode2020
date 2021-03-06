:- ['../lib/io.pl'].

part1(Ans) :-
    X + Y #= 2020,
    num(X), num(Y),
    all_distinct([X, Y]),
    Ans #= X*Y.

part2(Ans) :-
    X + Y + Z #= 2020,
    num(X), num(Y), num(Z),
    all_distinct([X, Y, Z]),
    Ans #= X*Y*Z.

parse --> parse_int, blanks, eos.
parse --> parse_int, blanks, parse.

parse_int -->
    integer(Num),
    {assertz(num(Num))}.

run :-
    input_stream(1, parse),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
