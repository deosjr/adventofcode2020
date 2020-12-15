:- ['../lib/io.pl'].

stabilize(Grid, N, Direct, Stable) :-
    trie_new(Neighbours),
    findall(C, (trie_gen_compiled(Grid,C,empty), cache_neighbours(Grid, Neighbours, Direct, C)), _),

    findall(C, (
        trie_gen_compiled(Grid,C,empty),
        in_view(Grid, Stable, Neighbours, Direct, C, E, _),
        E #> 8-N,
        trie_insert(Stable, C, occupied)
    ), FirstKnownOccupied),

    findall(C, (trie_gen_compiled(Grid, C, floor), trie_insert(Stable,C,floor)), _),

    new_to_check(Stable, Neighbours, FirstKnownOccupied, ToCheck),
    stabilize_rec(Grid, Stable, Neighbours, N, Direct, ToCheck).

new_to_check(Stable, NNs, NewlyAdded, ToCheck) :-
    maplist(trie_lookup(NNs), NewlyAdded, ToCheckNested),
    flatten(ToCheckNested, ToCheckWithDoubles),
    list_to_set(ToCheckWithDoubles, NewToCheck),
    exclude([C]>>(trie_lookup(Stable, C, _)), NewToCheck, ToCheck).
    
stabilize_rec(Grid, Stable, Neighbours, N, Direct, ToCheck) :-
    maplist([C, Out]>>(in_view(Grid, Stable, Neighbours, Direct, C, Empty, Occupied), Out=[C,Empty,Occupied]), ToCheck, List),
    include({N}/[[C,E,O]]>>(
        (O #> 0, trie_insert(Stable,C,empty))
        ; ( O #= 0, E #> 8-N, trie_insert(Stable,C,occupied))
    ), List, NewlyAddedPairs),
    maplist([[C,_,_],X]>>(X=C), NewlyAddedPairs, NewlyAdded),

    new_to_check(Stable, Neighbours, NewlyAdded, NewToCheck),
    (
        NewToCheck = []
    ->
        true
    ;
        stabilize_rec(Grid, Stable, Neighbours, N, Direct, NewToCheck)
    ).

neighbours([c(-1,-1),c(-1,1),c(-1,0),c(1,-1),c(1,1),c(1,0),c(0,-1),c(0,1)]).

cache_neighbours(Grid, NNs, Direct, Coord) :-
    neighbours(DXs),
    foldl([A,B,C]>>(
        (
            get_neighbours_rec(Grid, Direct, Coord, A, Ns)
        ->
            append(Ns, B, C)
        ;
            C = B
        )
    ), DXs, [], Neighbours),
    trie_insert(NNs, Coord, Neighbours).

get_neighbours_rec(Grid, Direct, X-Y, c(DX,DY), Neighbours) :-
    NX #= X + DX, NY #= Y + DY,
    trie_lookup(Grid, NX-NY, Value),
    (
        Value = floor
    ->
        (
            Direct
        ->
            Neighbours = [NX-NY]
        ;
            get_neighbours_rec(Grid, false, NX-NY, c(DX,DY), Neighbours)
        )
    ;
        % because it should never be occ in old grid
        Value = empty,
        Neighbours = [NX-NY]
    ).

in_view(Grid, Stable, NNs, Direct, Coord, PermanentEmpty, PermanentOccupied) :-
    trie_lookup(NNs, Coord, Neighbours),
    length(Neighbours, N),
    StartPermEmpty #= 8 - N,
    foldl([A,B,C]>>(
        in_view_rec(Grid, Stable, Direct, A, Empty, Occ),
        B = EmptyAcc-OccAcc,
        NEmpty #= Empty + EmptyAcc, NOcc #= Occ + OccAcc,
        C = NEmpty-NOcc
    ), Neighbours, StartPermEmpty-0, PermanentEmpty-PermanentOccupied).

in_view_rec(Grid, Stable, Direct, Coord, Empty, Occupied) :-
    trie_lookup(Grid, Coord, Value),
    (
        Value = floor
    ->
        (
            Direct
        ->
            Empty #= 1, Occupied #= 0
        ;
            Empty #= 0, Occupied #= 0
        )
    ;
        % because it should never be occ in old grid
        Value = empty,
        (
            trie_lookup(Stable, Coord, NewValue)
        ->
            (
                NewValue = empty
            ->
                Empty #= 1, Occupied #= 0
            ;
                % no floors in newgrid
                NewValue = occupied,
                Empty #= 0, Occupied #= 1
            )
        ;
            Empty #= 0, Occupied #= 0
        )
    ).

sumOccupied(Trie, Ans) :-
    findall(C, trie_gen_compiled(Trie, C, occupied), List),
    length(List, Ans).

part1(Grid, Ans) :-
    trie_new(Stable),
    stabilize(Grid, 4, true, Stable),
    sumOccupied(Stable, Ans).

part2(Grid, Ans) :-
    trie_new(Stable),
    stabilize(Grid, 5, false, Stable),
    sumOccupied(Stable, Ans).

parse(Trie, Y) --> parse(0, Y, Line), blanks, {NY #= Y+1},
    parse(Trie, NY), {add_line_to_trie(Trie, Line)}.

parse(Trie, Y) --> parse(0, Y, Line), blanks, eos, {add_line_to_trie(Trie, Line)}.

parse(_, _, []) --> "\n".
parse(X, Y, [grid(X-Y,floor)|T]) --> ".", {NX #= X+1}, parse(NX, Y, T).
parse(X, Y, [grid(X-Y,empty)|T]) --> "L", {NX #= X+1}, parse(NX, Y, T).

add_line_to_trie(_, []).
add_line_to_trie(Trie, [grid(K, V)|T]) :-
    trie_insert(Trie, K, V),
    add_line_to_trie(Trie, T).

run :-
    trie_new(Trie),
    input_stream(11, parse(Trie, 0)),
    part1(Trie, Ans1),
    write_part1(Ans1),
    part2(Trie, Ans2),
    write_part2(Ans2).
