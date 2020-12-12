:- ['../lib/io.pl'].

:- dynamic([grid/2, stable/2, nns/2]).

stabilize(N, Direct) :-
    findall(C, (grid(C,empty), assert_neighbours(Direct, C)), _),

    findall(C, (
        grid(C,empty),
        in_view(Direct, C, E, _),
        E #> 8-N,
        assertz(stable(C,occupied))
    ), FirstKnownOccupied),

    findall(C, (grid(C, floor), assertz(stable(C,floor))), _),

    new_to_check(FirstKnownOccupied, ToCheck),
    stabilize_rec(N, Direct, ToCheck).

new_to_check(NewlyAdded, ToCheck) :-
    maplist(nns, NewlyAdded, ToCheckNested),
    flatten(ToCheckNested, ToCheckWithDoubles),
    list_to_set(ToCheckWithDoubles, NewToCheck),
    exclude([C]>>(stable(C, _)), NewToCheck, ToCheck).
    
stabilize_rec(N, Direct, ToCheck) :-
    maplist([C, Out]>>(in_view(Direct, C, Empty, Occupied), Out=[C,Empty,Occupied]), ToCheck, List),
    include({N}/[[C,E,O]]>>(
        (O #> 0, assertz(stable(C,empty)))
        ; ( O #= 0, E #> 8-N, assertz(stable(C,occupied))) 
    ), List, NewlyAddedPairs),
    maplist([[C,_,_],X]>>(X=C), NewlyAddedPairs, NewlyAdded),

    new_to_check(NewlyAdded, NewToCheck),
    (
        NewToCheck = []
    ->
        true
    ;
        stabilize_rec(N, Direct, NewToCheck)
    ).

neighbours([c(-1,-1),c(-1,1),c(-1,0),c(1,-1),c(1,1),c(1,0),c(0,-1),c(0,1)]).

assert_neighbours(Direct, Coord) :-
    neighbours(DXs),
    foldl([A,B,C]>>(
        (
            get_neighbours_rec(Direct, Coord, A, Ns)
        ->
            append(Ns, B, C)
        ;
            C = B
        )
    ), DXs, [], Neighbours),
    assertz(nns(Coord, Neighbours)).

get_neighbours_rec(Direct, X-Y, c(DX,DY), Neighbours) :-
    NX #= X + DX, NY #= Y + DY,
    grid(NX-NY, Value),
    (
        Value = floor
    ->
        (
            Direct
        ->
            Neighbours = [NX-NY]
        ;
            get_neighbours_rec(false, NX-NY, c(DX,DY), Neighbours)
        )
    ;
        % because it should never be occ in old grid
        Value = empty,
        Neighbours = [NX-NY]
    ).

in_view(Direct, Coord, PermanentEmpty, PermanentOccupied) :-
    nns(Coord, Neighbours),
    length(Neighbours, N),
    StartPermEmpty #= 8 - N,
    foldl([A,B,C]>>(
        in_view_rec(Direct, A, Empty, Occ),
        B = EmptyAcc-OccAcc,
        NEmpty #= Empty + EmptyAcc, NOcc #= Occ + OccAcc,
        C = NEmpty-NOcc
    ), Neighbours, StartPermEmpty-0, PermanentEmpty-PermanentOccupied).

in_view_rec(Direct, Coord, Empty, Occupied) :-
    grid(Coord, Value),
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
            stable(Coord, NewValue)
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

sumOccupied(Ans) :-
    findall(C, stable(C, occupied), List),
    length(List, Ans).

part1(Ans) :-
    stabilize(4, true),
    sumOccupied(Ans).

part2(Ans) :-
    retractall(stable(_,_)),
    retractall(nns(_,_)),
    stabilize(5, false),
    sumOccupied(Ans).

parse(Y) --> parse(0, Y, Line), blanks, {NY #= Y+1},
    parse(NY), {assert_line(Line)}.

parse(Y) --> parse(0, Y, Line), blanks, eos, {assert_line(Line)}.

parse(_, _, []) --> "\n".
parse(X, Y, [grid(X-Y,floor)|T]) --> ".", {NX #= X+1}, parse(NX, Y, T).
parse(X, Y, [grid(X-Y,empty)|T]) --> "L", {NX #= X+1}, parse(NX, Y, T).

assert_line([]).
assert_line([H|T]) :-
    assertz(H),
    assert_line(T).

run :-
    input_stream(11, parse(0)),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
