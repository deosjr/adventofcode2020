:- ['../lib/io.pl'].

part1(List, Ans) :- 
    max_list(List, Ans).

part2(List, Ans) :-
    min_list(List, Min),
    max_list(List, Max),
    list_to_set(List, Set),
    numlist(Min, Max, AllBoardingPasses),
    list_to_set(AllBoardingPasses, BoardingPassSet),
    subtract(BoardingPassSet, Set, [Ans]).

parse([SID]) --> parse_boardingpass(N), blank, eos, {seatid(N, SID)}.
parse([SID|T]) --> parse_boardingpass(N), blank, parse(T), {seatid(N, SID)}.

seatid(BinaryChars, SeatID) :-
    string_chars(S, BinaryChars),
    string_concat("0b", S, B),
    number_string(SeatID, B).

parse_boardingpass(['0']) --> ("F";"L").
parse_boardingpass(['0'|T]) --> ("F";"L"), parse_boardingpass(T).
parse_boardingpass(['1']) --> ("B";"R").
parse_boardingpass(['1'|T]) --> ("B";"R"), parse_boardingpass(T).

run :-
    input_stream(5, parse(BoardingPasses)),
    part1(BoardingPasses, Ans1),
    write_part1(Ans1),
    part2(BoardingPasses, Ans2),
    write_part2(Ans2).
