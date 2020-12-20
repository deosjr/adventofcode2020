:- ['../lib/io.pl'].

:- dynamic([tile/2, border/2]).

part1(Tiles, Ans) :-
    corners(Tiles, Corners),
    foldl([T,Y,Z]>>(T = tile(X,_), Z#=X*Y), Corners, 1, Ans).

part2(Ans) :- true.

corners(Tiles, Corners) :-
    include([tile(Tile,_)]>>(
        findall(X, (
            border(Tile, Border),
            (
                border(X, Border)
            ;
                reverse(Border, Rev),
                border(X, Rev)
            ),
            X \= Tile
        ), Borders),
        length(Borders, 2)
    ), Tiles, Corners).

parse([]) --> blanks, eos.
parse([H|T]) --> parse_tile(H), parse(T).

parse_tile(tile(ID, Lines)) -->
    parse_id(ID), parse_lines(Lines).

parse_id(ID) --> "Tile ", integer(ID), ":\n".

parse_lines([]) --> "\n".
parse_lines([H|T]) --> string_without("\n", H), "\n", parse_lines(T).

assert_tile(tile(ID, Lines)) :-
    Lines = [
    [A0,B0,C0,D0,E0,F0,G0,H0,I0,J0],
    [A1, _, _, _, _, _, _, _, _,J1],
    [A2, _, _, _, _, _, _, _, _,J2],
    [A3, _, _, _, _, _, _, _, _,J3],
    [A4, _, _, _, _, _, _, _, _,J4],
    [A5, _, _, _, _, _, _, _, _,J5],
    [A6, _, _, _, _, _, _, _, _,J6],
    [A7, _, _, _, _, _, _, _, _,J7],
    [A8, _, _, _, _, _, _, _, _,J8],
    [A9,B9,C9,D9,E9,F9,G9,H9,I9,J9]
    ],
    assertz(border(ID, [A0,B0,C0,D0,E0,F0,G0,H0,I0,J0])),
    assertz(border(ID, [J0,J1,J2,J3,J4,J5,J6,J7,J8,J9])),
    assertz(border(ID, [J9,I9,H9,G9,F9,E9,D9,C9,B9,A9])),
    assertz(border(ID, [A9,A8,A7,A6,A5,A4,A3,A2,A1,A0])).

run :-
    input_stream(20, parse(Tiles)),
    forall(member(T, Tiles), (
        assert_tile(T)
    )),
    part1(Tiles, Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
