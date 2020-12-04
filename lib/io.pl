:- use_module(library(clpfd)).
:- use_module(library(pure_input)).
:- use_module(library(dcg/basics)).

read_file(Day, String) :-
    format(string(Padded), "~|~`0t~d~2+", [Day]),
    format(string(Filename), "~w/day~w.input", [Padded, Padded]),
    read_file_to_string(Filename, String, []).

% reads input and splits on a separator
read_and_split(Day, Sep, Split) :-
    read_file(Day, String),
    split_string(String, Sep, "", SplitRaw),
    select("", SplitRaw, Split).

zip([], [], []).
zip([X|XT], [Y|YT], [X-Y|ZT]) :-
    zip(XT, YT, ZT).

enumerate(List, Enumerated) :-
    length(List, N),
    N0 #= N-1,
    numlist(0, N0, Indices),
    zip(Indices, List, Enumerated).

% Lambda is a predicate that asserts facts for a line.
input_stream(Day, Lambda) :-
    format(string(Padded), "~|~`0t~d~2+", [Day]),
    format(string(Filename), "~w/day~w.input", [Padded, Padded]),
    open(Filename, read, Stream),
    phrase_from_stream(Lambda, Stream).
    
write_part1(Answer) :-
    format("Part 1: ~w~n", [Answer]).

write_part2(Answer) :-
    format("Part 2: ~w~n", [Answer]).
