:- ['../lib/io.pl'].

count(C, String, Count) :-
    include([X]>>(X=C), String, Filtered),
    length(Filtered, Count).

valid1(pwd(Min, Max, C, Pwd)) :-
    count(C, Pwd, Count),
    Min #=< Count,
    Max #>= Count.

part1(List, Ans) :-
    include(valid1, List, Filtered),
    length(Filtered, Ans).

valid2(pwd(Min, Max, C, Pwd)) :-
    get_string_code(Min, Pwd, A),
    get_string_code(Max, Pwd, B),
    ((A=C,B\=C);(A\=C,B=C)).

part2(List, Ans) :-
    include(valid2, List, Filtered),
    length(Filtered, Ans).

parse([Pwd]) --> parse_line(Pwd), blanks, eos.
parse([Pwd|T]) --> parse_line(Pwd), blanks, parse(T).

parse_line(pwd(Min, Max, C, Pwd)) -->
    integer(Min), "-", integer(Max),
    " ", alpha_to_lower(C), ": ", string_without("\n", Pwd).

run :-
    input_stream(2, parse(List)),
    part1(List, Ans1),
    write_part1(Ans1),
    part2(List, Ans2),
    write_part2(Ans2).
