:- ['../lib/io.pl'].

:- dynamic contains/3.

set_contains(Color, Set, New) :-
    findall(X, contains(X, _, Color), List),
    maplist([X,Y]>>(set_contains(X, [], Y)), List, Sets),
    foldl(union, [List|Sets], Set, New).

part1(Ans) :- 
    set_contains("shiny gold", [], Set),
    length(Set, Ans).

count_contains(Color, Sum) :-
    findall(N-X, contains(Color, N, X), List),
    maplist([N-X,Y]>>(count_contains(X, Count), Y=N-Count), List, Sets),
    foldl([N-X,Y,Z]>>(Z #= Y + N + N*X), Sets, 0, Sum).

part2(Ans) :-
    count_contains("shiny gold", Ans).

parse --> parse_line, "\n", parse.
parse --> parse_line, blanks, eos.

parse_line --> parse_color(C), " bags contain ", parse_contents(C).

parse_contents(_) --> "no other bags.". 
parse_contents(C) --> parse_content(N, S), ".", {assertz(contains(C,N,S))}.
parse_contents(C) --> parse_content(N, S), ", ", parse_contents(C), {assertz(contains(C,N,S))}.

parse_content(N, S) --> integer(N), " ", parse_color(S), " ", ("bag"; "bags").

parse_color(S) --> string_without(" ", Mod), " ", string_without(" ", Col), 
    {string_codes(MStr, Mod), string_codes(CStr, [32|Col]), string_concat(MStr, CStr, S)}.

run :-
    input_stream(7, parse),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
