:- ['../lib/io.pl'].

maplistfoldsum(List, Predicate, Ans) :-
    maplist([[H|T],X]>>(foldl(Predicate, T, H, X)), List, Unions),
    foldl([X,Y,Z]>>(length(X,N), Z#=Y+N), Unions, 0, Ans).

part1(List, Ans) :-
    maplistfoldsum(List, union, Ans).

part2(List, Ans) :-
    maplistfoldsum(List, intersection, Ans).

parse([Group]) --> parse_group(Group), blanks, eos.
parse([Group|T]) --> parse_group(Group), "\n\n", parse(T).

parse_group([H]) --> parse_person(H).
parse_group([H|T]) --> parse_person(H), "\n", parse_group(T).

parse_person(Set) --> string_without(" \n", P),
    {length(P, N), N#>0, list_to_set(P, Set)}.

run :-
    input_stream(6, parse(Groups)),
    part1(Groups, Ans1),
    write_part1(Ans1),
    part2(Groups, Ans2),
    write_part2(Ans2).
