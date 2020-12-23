:- ['../lib/io.pl'].

part1(Cups, Ans) :-
    domoves(100, Cups, NewCups),
    append(Prefix, [1], OnePref),
    append(OnePref, Suffix, NewCups),
    append(Suffix, Prefix, Ans).

domoves(0, X, X).
domoves(N, OldCups, NewCups) :-
    N #> 0,
    NN #= N - 1,
    move(OldCups, Cups),
    domoves(NN, Cups, NewCups).

part2(Ans) :- true.

move(Cups, NewCups) :-
    Cups = [Current, A, B, C | Rest],
    destination(Current, Rest, Dest),
    Rest = [NewCurrent|_],

    append(Prefix, [Dest], DestPref),
    append(DestPref, Suffix, [Current|Rest]),
    append(Prefix, [Dest, A, B, C | Suffix], NewCupsUnrotated),

    append(Pref2, [NewCurrent], NewCurrentPref),
    append(NewCurrentPref, NewCurrentSuf, NewCupsUnrotated),
    append([NewCurrent|NewCurrentSuf], Pref2, NewCups).

destination(Current, Rest, Dest) :-
    include(#>(Current), Rest, Smaller),
    ( Smaller = [] -> max_list(Rest, Dest)
    ; max_list(Smaller, Dest)).

parse(Cups) --> string_without("\n", Cups), blanks, eos.

run :-
    input_stream(23, parse(Cups)),
    maplist([X,Y]>>(number_codes(Y, [X])), Cups, Nums),
    %Nums = [3,8,9,1,2,5,4,6,7],
    part1(Nums, Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
