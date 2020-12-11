:- ['../lib/io.pl'].

% TODO: build up Chairs as list of coords and Floors as a dict in parsing
stabilize(Grid, N, Direct, StableGrid) :-
    dict_keys(Grid, Keys),
    include({Grid}/[Key]>>(get_dict(Key, Grid, empty)), Keys, ChairKeys),
    maplist([Key,X-Y]>>([X,Y] ins 0..99, key(X, Y, Key), label([X,Y])), ChairKeys, Chairs),

    neighbours(Neighbours),
    ViewPred = in_view(Grid, Direct, Neighbours),
    include([C]>>(call(ViewPred, C, _{}, E, _), E #> 8-N), Chairs, FirstKnownOccupied),

    maplist([X-Y,Pair]>>(key(X, Y, Key), Pair=Key-occupied), FirstKnownOccupied, FirstPairs),
    dict_pairs(FirstEntries, _, FirstPairs),
    NeighboursPred = get_neighbours(Grid, Direct, Neighbours),

    include({Grid}/[Key]>>(get_dict(Key, Grid, floor)), Keys, FloorKeys),
    maplist([Key,Entry]>>(Entry=Key-floor), FloorKeys, FloorPairs),
    dict_pairs(FloorEntries, _, FloorPairs),
    NewGrid = FloorEntries.put(FirstEntries),

    new_to_check(NeighboursPred, FirstKnownOccupied, NewGrid, ToCheck),
    stabilize_rec(N, ViewPred, NeighboursPred, ToCheck, FirstEntries, StableGrid).

new_to_check(NeighboursPred, NewlyAdded, NewGrid, ToCheck) :-
    maplist(NeighboursPred, NewlyAdded, ToCheckNested),
    flatten(ToCheckNested, ToCheckWithDoubles),
    list_to_set(ToCheckWithDoubles, NewToCheck),
    exclude([X-Y]>>(key(X, Y, Key), get_dict(Key, NewGrid, _)), NewToCheck, ToCheck).
    
stabilize_rec(N, ViewPred, NeighboursPred, ToCheck, GridAcc, StableGrid) :-
    %length(ToCheck, TEST), writeln(TEST),
    maplist({ViewPred, GridAcc}/[C, Out]>>(call(ViewPred, C, GridAcc, Empty, Occupied), Out=[C,Empty,Occupied]), ToCheck, List),
    include([[_,_,Occupied]]>>(Occupied #> 0), List, PermEmpty),
    include([[_,Empty,Occupied]]>>(Occupied #= 0, Empty #> 8-N), List, PermOccupied),
    maplist([[C,_,_],A]>>(A=C), PermEmpty, PermEmptyCoords),
    maplist([[C,_,_],A]>>(A=C), PermOccupied, PermOccupiedCoords),
    append(PermEmptyCoords, PermOccupiedCoords, NewlyAdded),
    maplist([X-Y,Z]>>(key(X,Y,Key), Z=Key-empty), PermEmptyCoords, PermEmptyEntries),
    maplist([X-Y,Z]>>(key(X,Y,Key), Z=Key-occupied), PermOccupiedCoords, PermOccupiedEntries),
    append(PermEmptyEntries, PermOccupiedEntries, Entries),
    dict_pairs(ToAdd, _, Entries),
    NewGrid = GridAcc.put(ToAdd),
    new_to_check(NeighboursPred, NewlyAdded, NewGrid, NewToCheck),
    (
        NewToCheck = []
    ->
        NewGrid = StableGrid
    ;
        stabilize_rec(N, ViewPred, NeighboursPred, NewToCheck, NewGrid, StableGrid)
    ).

neighbours([c(-1,-1),c(-1,1),c(-1,0),c(1,-1),c(1,1),c(1,0),c(0,-1),c(0,1)]).

get_neighbours(Grid, Direct, DXs, X-Y, Neighbours) :-
    Closure = get_neighbours_rec(Grid, Direct, X-Y),
    foldl([A,B,C]>>(
        call(Closure, A, [], Ns),
        append(Ns, B, C)
    ), DXs, [], Neighbours).

get_neighbours_rec(Grid, Direct, X-Y, c(DX,DY), Sofar, Neighbours) :-
    NX #= X + DX, NY #= Y + DY,
    (
        dict_get(Grid, NX, NY, Value)
    ->
        NewNeighbours = [NX-NY|Sofar],
        (
            Value = floor
        ->
            (
                Direct
            ->
                Neighbours = NewNeighbours
            ;
                get_neighbours_rec(Grid, false, NX-NY, c(DX,DY), NewNeighbours, Neighbours)
            )
        ;
            % because it should never be occ in old grid
            Value = empty,
            Neighbours = NewNeighbours
        )
    ;
        Neighbours = Sofar
    ).

in_view(Grid, Direct, Neighbours, X-Y, NewGrid, PermanentEmpty, PermanentOccupied) :-
    Closure = in_view_rec(Grid, NewGrid, Direct, X-Y),
    foldl([A,B,C]>>(
        call(Closure, A, Empty, Occ),
        B = EmptyAcc-OccAcc,
        NEmpty #= Empty + EmptyAcc, NOcc #= Occ + OccAcc,
        C = NEmpty-NOcc
    ), Neighbours, 0-0, PermanentEmpty-PermanentOccupied).

in_view_rec(Grid, NewGrid, Direct, X-Y, c(DX,DY), Empty, Occupied) :-
    NX #= X + DX, NY #= Y + DY,
    (
        dict_get(Grid, NX, NY, Value)
    ->
        (
            Value = floor
        ->
            (
                Direct
            ->
                Empty #= 1, Occupied #= 0
            ;
                in_view_rec(Grid, NewGrid, false, NX-NY, c(DX,DY), Empty, Occupied)
            )
        ;
            % because it should never be occ in old grid
            Value = empty,
            (
                dict_get(NewGrid, NX, NY, NewValue)
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
        )
    ;
        Empty #= 1, Occupied #= 0
    ).

sumOccupied(Grid, Ans) :-
    findall(X, get_dict(X, Grid, occupied), List),
    length(List, Ans).

part1(Grid, Ans) :-
    stabilize(Grid, 4, true, StableGrid),
    sumOccupied(StableGrid, Ans).

part2(Grid, Ans) :-
    stabilize(Grid, 5, false, StableGrid),
    sumOccupied(StableGrid, Ans).

parse(Y, Grid) --> parse(0, Y, Partial), blanks, {NY #= Y+1},
    parse(NY, Rest), {Grid = Rest.put(Partial)}.

parse(Y, Grid) --> parse(0, Y, Grid), blanks, eos.

parse(_, _, _{}) --> "\n".
parse(X, Y, Grid) --> ".", {NX #= X+1}, parse(NX, Y, Rest), {dict_set(Rest, X, Y, floor, Grid)}.
parse(X, Y, Grid) --> "L", {NX #= X+1}, parse(NX, Y, Rest), {dict_set(Rest, X, Y, empty, Grid)}.

dict_set(Dict, X, Y, Value, New) :-
    key(X, Y, Key),
    dict_create(Update, _, [Key=Value]),
    New = Dict.put(Update).

dict_get(Dict, X, Y, Value) :-
    key(X, Y, Key),
    get_dict(Key, Dict, Value).

% cant have composite keys, so we hash. 
% input is less than 100 lines and each line is 90 chars
% so this shouldnt clash
key(X, Y, Key) :- Key #= 100 * Y + X.

% TODO: runs in around 5mins and still does not find the exact right answer (but close :') )
run :-
    input_stream(11, parse(0, Grid)),
    part1(Grid, Ans1),
    write_part1(Ans1),
    part2(Grid, Ans2),
    write_part2(Ans2).
