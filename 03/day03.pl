:- ['../lib/io.pl'].

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

assert_trees(Y, Line) :-
    enumerate(Line, Enumerated),
    forall(member(X-C, Enumerated), (
        char_code(Char, C),
        (Char = '.' ; (Char = '#', assertz(tree(X,Y))))
    )).

parse(Y) -->
    string_without("\n", Line), blanks, eos,
    {assert_trees(Y, Line),
    length(Line, MaxX), assertz(maxX(MaxX)),
    assertz(maxY(Y))}.

parse(Y) -->
    string_without("\n", Line), blanks,
    {assert_trees(Y, Line), NY#=Y+1},
    parse(NY).

run :-
    input_stream(3, parse(0)),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
