:- ['../lib/io.pl'].

:- dynamic([grid/3, stable/3]).

stabilize(N, Direct) :-
    neighbours(Neighbours),
    ViewPred = in_view(Direct, Neighbours),

    findall(X-Y, (
        grid(X,Y,empty),
        call(ViewPred, X-Y, E, _),
        E #> 8-N
    ), FirstKnownOccupied),

    forall(member(X-Y, FirstKnownOccupied), assertz(stable(X,Y,occupied))),

    NeighboursPred = get_neighbours(Direct, Neighbours),

    findall(X-Y, grid(X, Y, floor), Floors),
    forall(member(X-Y, Floors), assertz(stable(X,Y,floor))),

    new_to_check(NeighboursPred, FirstKnownOccupied, ToCheck),
    stabilize_rec(N, ViewPred, NeighboursPred, ToCheck).

new_to_check(NeighboursPred, NewlyAdded, ToCheck) :-
    maplist(NeighboursPred, NewlyAdded, ToCheckNested),
    flatten(ToCheckNested, ToCheckWithDoubles),
    list_to_set(ToCheckWithDoubles, NewToCheck),
    exclude([X-Y]>>(stable(X,Y,_)), NewToCheck, ToCheck).
    
stabilize_rec(N, ViewPred, NeighboursPred, ToCheck) :-
    maplist({ViewPred}/[C, Out]>>(call(ViewPred, C, Empty, Occupied), Out=[C,Empty,Occupied]), ToCheck, List),
    include([[_,_,Occupied]]>>(Occupied #> 0), List, PermEmpty),
    include([[_,Empty,Occupied]]>>(Occupied #= 0, Empty #> 8-N), List, PermOccupied),
    maplist([[C,_,_],A]>>(A=C), PermEmpty, PermEmptyCoords),
    maplist([[C,_,_],A]>>(A=C), PermOccupied, PermOccupiedCoords),
    append(PermEmptyCoords, PermOccupiedCoords, NewlyAdded),
    forall(member(X-Y, PermEmptyCoords), assertz(stable(X,Y,empty))),
    forall(member(X-Y, PermOccupiedCoords), assertz(stable(X,Y,occupied))),
    new_to_check(NeighboursPred, NewlyAdded, NewToCheck),
    (
        NewToCheck = []
    ->
        true
    ;
        stabilize_rec(N, ViewPred, NeighboursPred, NewToCheck)
    ).

neighbours([c(-1,-1),c(-1,1),c(-1,0),c(1,-1),c(1,1),c(1,0),c(0,-1),c(0,1)]).

get_neighbours(Direct, DXs, X-Y, Neighbours) :-
    Closure = get_neighbours_rec(Direct, X-Y),
    foldl([A,B,C]>>(
        call(Closure, A, [], Ns),
        append(Ns, B, C)
    ), DXs, [], Neighbours).

get_neighbours_rec(Direct, X-Y, c(DX,DY), Sofar, Neighbours) :-
    NX #= X + DX, NY #= Y + DY,
    (
        grid(NX, NY, Value)
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
                get_neighbours_rec(false, NX-NY, c(DX,DY), NewNeighbours, Neighbours)
            )
        ;
            % because it should never be occ in old grid
            Value = empty,
            Neighbours = NewNeighbours
        )
    ;
        Neighbours = Sofar
    ).

in_view(Direct, Neighbours, X-Y, PermanentEmpty, PermanentOccupied) :-
    Closure = in_view_rec(Direct, X-Y),
    foldl([A,B,C]>>(
        call(Closure, A, Empty, Occ),
        B = EmptyAcc-OccAcc,
        NEmpty #= Empty + EmptyAcc, NOcc #= Occ + OccAcc,
        C = NEmpty-NOcc
    ), Neighbours, 0-0, PermanentEmpty-PermanentOccupied).

in_view_rec(Direct, X-Y, c(DX,DY), Empty, Occupied) :-
    NX #= X + DX, NY #= Y + DY,
    (
        grid(NX, NY, Value)
    ->
        (
            Value = floor
        ->
            (
                Direct
            ->
                Empty #= 1, Occupied #= 0
            ;
                in_view_rec(false, NX-NY, c(DX,DY), Empty, Occupied)
            )
        ;
            % because it should never be occ in old grid
            Value = empty,
            (
                stable(NX, NY, NewValue)
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

sumOccupied(Ans) :-
    findall(X-Y, stable(X, Y, occupied), List),
    length(List, Ans).

part1(Ans) :-
    stabilize(4, true),
    sumOccupied(Ans).

part2(Ans) :-
    retractall(stable(_,_,_)),
    stabilize(5, false),
    sumOccupied(Ans).

parse(Y) --> parse(0, Y, Line), blanks, {NY #= Y+1},
    parse(NY), {assert_line(Line)}.

parse(Y) --> parse(0, Y, Line), blanks, eos, {assert_line(Line)}.

parse(_, _, []) --> "\n".
parse(X, Y, [grid(X,Y,floor)|T]) --> ".", {NX #= X+1}, parse(NX, Y, T).
parse(X, Y, [grid(X,Y,empty)|T]) --> "L", {NX #= X+1}, parse(NX, Y, T).

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
