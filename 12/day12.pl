:- ['../lib/io.pl'].

turn_left_once(HX-HY, NHX-NHY) :-
    NHX #= -HY, NHY #= HX.

turn_left(Old, Degrees, New) :-
    Turns #= Degrees // 90,
    numlist(1, Turns, Iterator),
    foldl([_,Y,Z]>>(turn_left_once(Y,Z)), Iterator, Old, New).

turn_right_once(HX-HY, NHX-NHY) :-
    NHX #= HY, NHY #= -HX.

turn_right(Old, Degrees, New) :-
    Turns #= Degrees // 90,
    numlist(1, Turns, Iterator),
    foldl([_,Y,Z]>>(turn_right_once(Y,Z)), Iterator, Old, New).

part1(Instructions, Ans) :-
    p1_loop(0-0, 1-0, Instructions, Ans).

p1_loop(PX-PY, _, [], Ans) :-
    Ans #= abs(PX) + abs(PY).

p1_loop(PX-PY, Heading, [instr(north, Value)|T], Ans) :-
    NPY #= PY + Value,
    p1_loop(PX-NPY, Heading, T, Ans).
p1_loop(PX-PY, Heading, [instr(south, Value)|T], Ans) :-
    NPY #= PY - Value,
    p1_loop(PX-NPY, Heading, T, Ans).
p1_loop(PX-PY, Heading, [instr(east, Value)|T], Ans) :-
    NPX #= PX + Value,
    p1_loop(NPX-PY, Heading, T, Ans).
p1_loop(PX-PY, Heading, [instr(west, Value)|T], Ans) :-
    NPX #= PX - Value,
    p1_loop(NPX-PY, Heading, T, Ans).
p1_loop(Pos, Heading, [instr(left, Value)|T], Ans) :-
    turn_left(Heading, Value, NewHeading),
    p1_loop(Pos, NewHeading, T, Ans).
p1_loop(Pos, Heading, [instr(right, Value)|T], Ans) :-
    turn_right(Heading, Value, NewHeading),
    p1_loop(Pos, NewHeading, T, Ans).
p1_loop(PX-PY, HX-HY, [instr(forward, Value)|T], Ans) :-
    DX #= HX * Value, DY #= HY * Value, 
    NPX #= PX + DX, NPY #= PY + DY,
    p1_loop(NPX-NPY, HX-HY, T, Ans).

part2(Instructions, Ans) :-
    p2_loop(0-0, 10-1, Instructions, Ans).

p2_loop(PX-PY, _, [], Ans) :-
    Ans #= abs(PX) + abs(PY).

p2_loop(Pos, WX-WY, [instr(north, Value)|T], Ans) :-
    NWY #= WY + Value,
    p2_loop(Pos, WX-NWY, T, Ans).
p2_loop(Pos, WX-WY, [instr(south, Value)|T], Ans) :-
    NWY #= WY - Value,
    p2_loop(Pos, WX-NWY, T, Ans).
p2_loop(Pos, WX-WY, [instr(east, Value)|T], Ans) :-
    NWX #= WX + Value,
    p2_loop(Pos, NWX-WY, T, Ans).
p2_loop(Pos, WX-WY, [instr(west, Value)|T], Ans) :-
    NWX #= WX - Value,
    p2_loop(Pos, NWX-WY, T, Ans).
p2_loop(Pos, Waypoint, [instr(left, Value)|T], Ans) :-
    turn_left(Waypoint, Value, NewWaypoint),
    p2_loop(Pos, NewWaypoint, T, Ans).
p2_loop(Pos, Waypoint, [instr(right, Value)|T], Ans) :-
    turn_right(Waypoint, Value, NewWaypoint),
    p2_loop(Pos, NewWaypoint, T, Ans).
p2_loop(PX-PY, WX-WY, [instr(forward, Value)|T], Ans) :-
    DX #= WX * Value, DY #= WY * Value, 
    NPX #= PX + DX, NPY #= PY + DY,
    p2_loop(NPX-NPY, WX-WY, T, Ans).

parse([Ins|T]) --> parse_instruction(Ins), blanks, parse(T).
parse([Ins]) --> parse_instruction(Ins), blanks, eos.

parse_instruction(instr(I, N)) -->
    alpha_to_lower(Code), integer(N), {char_code(C, Code), action(C, I)}.

action('n', north).
action('s', south).
action('e', east).
action('w', west).
action('l', left).
action('r', right).
action('f', forward).

run :-
    input_stream(12, parse(Instructions)),
    part1(Instructions, Ans1),
    write_part1(Ans1),
    part2(Instructions, Ans2),
    write_part2(Ans2).
