:- ['../lib/io.pl'].

part1(List, Ans) :-
    length(List, Len),
    LenMin1 #= Len-1,
    I in 0..LenMin1,
    nth0(I, List, Ans),
    length(Preamble, 25),
    length(Prefix, I),
    append(_, Preamble, Prefix),
    append(Prefix, _, List),
    not((
        X + Y #= Ans,
        member(X, Preamble), member(Y, Preamble),
        all_distinct([X, Y])
    )).

part2(List, Ans1, Ans2) :-
    sliding_window(0, 1, List, Ans1, Ans2).

sliding_window(I, J, List, Ans1, Ans2) :-
    length(Before, I),
    length(Prefix, J),
    append(Before, AnsList, Prefix),
    append(Prefix, _, List),
    sum(AnsList, #=, Sum),
    (
        Sum #= Ans1
    ->
        min_list(AnsList, Min),
        max_list(AnsList, Max),
        Ans2 #= Min + Max
    ;
        (
            Sum #< Ans1
        ->
            NJ #= J+1,
            sliding_window(I, NJ, List, Ans1, Ans2)
        ;
            % Sum #> Ans1
            NI #= I+1,
            sliding_window(NI, J, List, Ans1, Ans2)
        )
    ).

parse([Num]) --> integer(Num), blanks, eos.
parse([Num|T]) --> integer(Num), blanks, parse(T).

run :-
    input_stream(9, parse(NumList)),
    part1(NumList, Ans1),
    write_part1(Ans1),
    part2(NumList, Ans1, Ans2),
    write_part2(Ans2).
