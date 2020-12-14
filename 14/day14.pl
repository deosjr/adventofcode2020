:- ['../lib/io.pl'].

:- dynamic mem/2.

sum_values(Sum) :-
    findall(X, mem(_, X), List),
    sum(List, #=, Sum).

part1(Instructions, Ans) :-
    loop(Instructions, _Mask, p1),
    sum_values(Ans).

part2(Instructions, Ans) :-
    retractall(mem(_,_)),
    loop(Instructions, _Mask, p2),
    sum_values(Ans).

loop([], _, _).

loop([Mask|T], _, Pred) :-
    Mask = mask(_,_,_),
    loop(T, Mask, Pred).

loop([set(Adr, Value)|T], Mask, Pred) :-
    call(Pred, Adr, Value, Mask),
    loop(T, Mask, Pred).

p1(Adr, Value, Mask) :-
    Mask = mask(MX, M1, _),
    N #= (Value /\ MX) \/ M1,
    assert_mem(Adr, N).

p2(_, _, mask(_, _, [])).
p2(Adr, Value, Mask) :-
    Mask = mask(MX, M1, [X|MXs]),
    N #= (( Adr \/ M1 ) \/ MX ) xor X,
    assert_mem(N, Value),
    p2(Adr, Value, mask(MX, M1, MXs)).

% Dictionaries did not perform well enough. Too many singular inserts.
assert_mem(Adr, Value) :-
    retractall(mem(Adr, _)),
    assertz(mem(Adr, Value)).

parse([]) --> blanks, eos.
parse([mask(PMX, PM1, PMXs)|T]) -->
    "mask = ", parse_mask(MX, M1, MXs), blanks, parse(T),
    {to_binary(MX, PMX), to_binary(M1, PM1),
    maplist(to_binary, MXs, PMXs)}.
parse([set(Adr, Value)|T]) -->
    "mem[", integer(Adr), "] = ", integer(Value), blanks, parse(T).

to_binary(Codes, N) :-
    string_codes(Str, Codes),
    string_concat("0b", Str, S),
    number_string(N, S).

combine([], []).
combine([H|T], [['1'|H], ['0'|H]|XT]) :-
    combine(T, XT).

pad_zeroes([], []).
pad_zeroes([H|T], [['0'|H]|XT]) :-
    pad_zeroes(T, XT).

% A mask is parsed into:
% - maskX  which has 1 for X and 0 for rest
% - mask1  which has 1 for 1 and 0 for rest
% - maskXs which is all possible masks in maskX
parse_mask([], [], [[]]) --> "\n".
parse_mask(['1'|MX], ['0'|M1], NewMXs) -->
    "X", parse_mask(MX, M1, MXs), {combine(MXs, NewMXs)}.
parse_mask(['0'|MX], ['1'|M1], NewMXs) -->
    "1", parse_mask(MX, M1, MXs), {pad_zeroes(MXs, NewMXs)}.
parse_mask(['0'|MX], ['0'|M1], NewMXs) -->
    "0", parse_mask(MX, M1, MXs), {pad_zeroes(MXs, NewMXs)}.

run :-
    input_stream(14, parse(Instructions)),
    part1(Instructions, Ans1),
    write_part1(Ans1),
    part2(Instructions, Ans2),
    write_part2(Ans2).
