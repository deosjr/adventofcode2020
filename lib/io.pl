%
read_and_split(Day, Split) :-
    format(string(Padded), "~|~`0t~d~2+", [Day]),
    format(string(Filename), "~w/day~w.input", [Padded, Padded]),
    read_file_to_string(Filename, String, []),
    split_string(String, "\n", "", SplitRaw),
    select("", SplitRaw, Split).

% Lambda is a predicate that asserts facts for a line.
input(Day, Lambda) :-
    read_and_split(Day, Split),
    forall(member(Line, Split), call(Lambda, Line)).

% enumerates lines, so lambda should expect num-str tuples
input_enumerated(Day, Lambda) :-
    read_and_split(Day, Split),
    enumerate(Split, Enumerated),
    forall(member(Line, Enumerated), call(Lambda, Line)).

zip([], [], []).
zip([X|XT], [Y|YT], [X-Y|ZT]) :-
    zip(XT, YT, ZT).

enumerate(List, Enumerated) :-
    length(List, N),
    N0 #= N-1,
    numlist(0, N0, Indices),
    zip(Indices, List, Enumerated).
    
% Pred is the name of the predicate to list.
% Arity is the arity of that predicate
% i.e. for day01, input_as_list with Pred=num
% binds List to the list of input numbers
input_as_list(Day, Lambda, Pred/Arity, List) :-
    input(Day, Lambda),
    findall(X, (functor(X, Pred, Arity), call(X)), List).

write_part1(Answer) :-
    format("Part 1: ~w~n", [Answer]).

write_part2(Answer) :-
    format("Part 2: ~w~n", [Answer]).
