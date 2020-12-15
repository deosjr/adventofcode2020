:- ['../lib/io.pl'].

% assumes numbers in list are unique
build_trie(List, StartTurn, Trie) :-
    length(List, N),
    StartTurn #= N + 1,
    numlist(1, N, Turns),
    trie_new(Trie),
    forall(member(T, Turns), (
        nth1(T, List, Number),
        trie_update(Trie, Number, T)
    )).

part1(List, Ans) :-
    build_trie(List, StartTurn, Trie),
    loop(Trie, StartTurn, 2020, 0, Ans).

part2(List, Ans) :-
    build_trie(List, StartTurn, Trie),
    loop(Trie, StartTurn, 30000000, 0, Ans).

loop(_, T, T, N, N).
loop(Trie, Turn, EndTurn, Num, Ans) :-
    Turn #< EndTurn,
    NewTurn #= Turn + 1,
    say(Trie, Num, Turn, NewNum),!,
    trie_update(Trie, Num, Turn),
    loop(Trie, NewTurn, EndTurn, NewNum, Ans).

say(Trie, Num, Turn, NewNum) :-
    ( trie_lookup(Trie, Num, PrevTurn) -> NewNum #= Turn - PrevTurn; NewNum #= 0 ).

parse([]) --> blanks, eos.
parse([N|T]) --> integer(N), parse(T).
parse([N|T]) --> ",", integer(N), parse(T).

% runs in ~45 seconds with Tries, vs 10mins using asserts
% interestingly, using recorda / recorded was almost as fast (>60s)
run :-
    input_stream(15, parse(List)),
    part1(List, Ans1),
    write_part1(Ans1),
    part2(List, Ans2),
    write_part2(Ans2).
