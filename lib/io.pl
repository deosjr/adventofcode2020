% Lambda is a predicate that asserts facts for a line.
input(Day, Lambda) :-
    format(string(Padded), "~|~`0t~d~2+", [Day]),
    format(string(Filename), "~w/day~w.input", [Padded, Padded]),
    read_file_to_string(Filename, String, []),
    split_string(String, "\n", "", SplitRaw),
    select("", SplitRaw, Split),
    forall(member(Line, Split), call(Lambda, Line)).
    
% Pred is the name of the predicate to list.
% i.e. for day01, input_as_list with Pred=num
% binds List to the list of input numbers
input_as_list(Day, Lambda, Pred, List) :-
    input(Day, Lambda),
    findall(X, call(Pred, X), List).

write_part1(Answer) :-
    format("Part 1: ~w~n", [Answer]).

write_part2(Answer) :-
    format("Part 2: ~w~n", [Answer]).
