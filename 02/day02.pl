:- use_module(library(clpfd)).

:- ['../lib/io.pl'].

count(C, String, Count) :-
    string_chars(String, Chars),
    include([X]>>(X=C), Chars, Filtered),
    length(Filtered, Count).

valid1(pwd(Min, Max, C, Pwd)) :-
    count(C, Pwd, Count),
    Min #=< Count,
    Max #>= Count.

part1(List, Ans) :-
    include(valid1, List, Filtered),
    length(Filtered, Ans).

valid2(pwd(Min, Max, C, Pwd)) :-
    char_code(C, X),
    get_string_code(Min, Pwd, A),
    get_string_code(Max, Pwd, B),
    ((A=X,B\=X);(A\=X,B=X)).

part2(List, Ans) :-
    include(valid2, List, Filtered),
    length(Filtered, Ans).

parse(Line) :-
    split_string(Line, " ", " ", Split),
    phrase(parse(Min, Max, C, Pwd), Split),
    assertz(pwd(Min, Max, C, Pwd)).

parse(Min, Max, C, Pwd) -->
    parse_minmax(Min, Max),
    parse_letter(C),
    [Pwd].

parse_minmax(Min, Max) --> 
    [MinMax], 
    {split_string(MinMax, "-", "", [MinS, MaxS]),
    number_string(Min, MinS),
    number_string(Max, MaxS)}.

parse_letter(C) --> 
    [S], {string_chars(S, [C|_])}.

run :-
    input_as_list(2, parse, pwd/4, List),
    part1(List, Ans1),
    write_part1(Ans1),
    part2(List, Ans2),
    write_part2(Ans2).
