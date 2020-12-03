:- use_module(library(clpfd)).

:- ['../lib/io.pl'].

:- dynamic([maxX/1, maxY/1]).
maxY(0).

parse(Y-Line) :-
    string_chars(Line, Chars),
    ( not(maxX(_)) -> length(Chars, N), assertz(maxX(N)); true ),
    enumerate(Chars, Enumerated),
    retract(maxY(_)), assertz(maxY(Y)),
    forall(member(X-C, Enumerated), (
        C = '.' ; (C = '#', assertz(tree(X,Y)))
    )).

trees(XIncr, YIncr, Ans) :-
    maxX(MaxX), maxY(MaxY),
    numlist(1, MaxY, Ys),
    include([X]>>(X mod YIncr #= 0), Ys, YList),
    maplist([Y,X-Y]>>(X#=(XIncr*(Y//YIncr)) mod MaxX), YList, Coords),
    foldl([X-Y,Old,New]>>(tree(X,Y)->New#=Old+1;New=Old), Coords, 0, Ans).

part1(Ans) :-
    trees(3, 1, Ans).

part2(Ans) :-
    trees(1, 1, R1D1),
    trees(3, 1, R3D1),
    trees(5, 1, R5D1),
    trees(7, 1, R7D1),
    trees(1, 2, R1D2),
    Ans #= R1D1 * R3D1 * R5D1 * R7D1 * R1D2.

run :-
    input_enumerated(3, parse),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
