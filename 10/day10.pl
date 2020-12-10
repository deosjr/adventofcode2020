:- ['../lib/io.pl'].

len_diffs(List, Diff, LenDiffs) :-
    length(List, LenList),
    numlist(1, LenList, NumList),
    include(get_diff(List, Diff), NumList, Out),
    length(Out, LenDiffs).

get_diff(List, Diff, X) :-
    nth1(X, List, N),
    Y #= X+1,
    nth1(Y, List, M),
    diff(N, M, Diff).

diff(X, Y, Diff) :-
    Y - X #= Diff.

part1(List, Ans) :-
    len_diffs(List, 1, X),
    len_diffs(List, 3, Y),
    Ans #= X * (Y+1).

sublists([], _, X, X).
sublists([H|T], Prev, [SH|ST], SubLists) :-
    (
        diff(Prev, H, 3)
    ->
        sublists(T, H, [[H],SH|ST], SubLists)
    ;
        sublists(T, H, [[H|SH]|ST], SubLists)
    ).

count_permutations([_], X, X).
count_permutations([_,_], X, X).
count_permutations([First,_,Last], Prev, Next) :-
    ( diff(First, Last, N), N #> 3 -> Next#=Prev; Next#=Prev*2 ).
count_permutations([_,_,_,_], Prev, Next) :-
    Next #= Prev*4.
count_permutations([_,_,_,_,_], Prev, Next) :-
    Next #= Prev*7.

part2(List, Ans) :-
    sublists(List, 0, [[]], SubLists),
    foldl(count_permutations, SubLists, 1, Ans).

parse([N]) --> integer(N), blanks, eos.
parse([N|T]) --> integer(N), blanks, parse(T).

run :-
    input_stream(10, parse(List)),
    sort([0|List], Sort),
    part1(Sort, Ans1),
    write_part1(Ans1),
    part2(Sort, Ans2),
    write_part2(Ans2).
