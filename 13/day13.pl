:- ['../lib/io.pl'].

part1(N, Buses, Ans) :-
    maplist([_-Bus,Y]>>(
        Wait #= Bus - (N mod Bus),
        Y = Wait-Bus
    ), Buses, Minutes),
    keysort(Minutes, [Min-Bus|_]),
    Ans #= Min * Bus.

sortpred(>, _-V1, _-V2) :-
    V1 #> V2.
sortpred(<, _-V1, _-V2) :-
    V1 #< V2.

part2(Buses, Ans) :-
    predsort(sortpred, Buses, Sorted),
    foldl([I-P, TS-N, NT-NN]>>(
        % output was bigger than 100000000000000
        % tuning M and T ranges speeds this up quite a bit ofc
        M in 1..100000000000000,
        T in 100000000000000..1000000000000000,
        T mod P #= -I mod P,
        T #= TS + M * N,
        label([T]),
        NT #= T, NN #= N * P
    ), Sorted, 0-1, Ans-_).

parse(N-Buses) --> integer(N), "\n", parse_buses(0, Buses).

parse_buses(I, [I-N]) --> integer(N), blanks, eos.
parse_buses(I,T) --> "x,", {J #= I+1}, parse_buses(J,T).
parse_buses(I,[I-N|T]) --> integer(N), ",", {J #= I+1}, parse_buses(J,T).

run :-
    input_stream(13, parse(N-Buses)),
    part1(N, Buses, Ans1),
    write_part1(Ans1),
    part2(Buses, Ans2),
    write_part2(Ans2).
