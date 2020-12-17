:- ['../lib/io.pl'].

make_set(List, Trie) :-
    trie_new(Trie),
    forall(member(C,List), trie_insert(Trie, C, true)).

set_contains(Set, Coord) :-
    trie_gen_compiled(Set, Coord, _).

set_elements(Set, Elements) :-
    findall(X, set_contains(Set, X), Elements).

set_size(Set, N) :-
    set_elements(Set, Elems),
    length(Elems, N).

to_check(List, ToCheck) :-
    trie_new(ToCheck),
    forall(member(C, List), (
        add_to_check(ToCheck, C)
    )).

add_to_check(ToCheck, C) :-
    neighbours(C, Ns),
    forall(member(N, [C|Ns]), (
        trie_update(ToCheck, N, true)
    )).

check_all(Set, NewSet, ToCheck, NewToCheck) :-
    trie_new(NewSet),
    trie_new(NewToCheck),
    set_elements(ToCheck, Elems),
    maplist(check(Set, NewSet, NewToCheck), Elems).

check(Set, NewSet, NewToCheck, C) :-
    sum_neighbours(Set, C, Sum),
    ( 
        set_contains(Set, C)
    ->
        ( (Sum #= 2 ; Sum #= 3 ) -> update(NewSet, NewToCheck, C) ; true )
    ;
        ( Sum #= 3 -> update(NewSet, NewToCheck, C) ; true )
    ).

update(Set, ToCheck, C) :-
    trie_update(Set, C, true),
    add_to_check(ToCheck, C).

sum_neighbours(Set, C, Sum) :-
    neighbours(C, Ns),
    include(set_contains(Set), Ns, ActiveNeighbours),
    length(ActiveNeighbours, Sum).
    % leaving this because this shaved off a full minute!!! (this was before changing neighbours/2)
    % rewriting foldl also sped up day 11 from 18s to 4s
    % foldl([X,Y,Z]>>(set_contains(Set, X) -> Z#=Y+1 ; Z#=Y), Ns, 0, Sum).

iterate(0, Set, Set, _).
iterate(N, Set, FinalSet, ToCheck) :-
    N #> 0,
    check_all(Set, NewSet, ToCheck, NewToCheck),
    NN #= N - 1,
    trie_destroy(Set),
    trie_destroy(ToCheck),
    iterate(NN, NewSet, FinalSet, NewToCheck).

iterate_6(List, Ans) :-
    make_set(List, Set),
    to_check(List, ToCheck),
    iterate(6, Set, NewSet, ToCheck),
    set_size(NewSet, Ans).

part1(List, Ans) :-
    maplist([X-Y,C]>>(C=c(X,Y,0)), List, List3D),
    iterate_6(List3D, Ans).

part2(List, Ans) :-
    maplist([X-Y,C]>>(C=c(X,Y,0,0)), List, List4D),
    iterate_6(List4D, Ans).

parse(List, Y) --> parse(0, Y, Line), blanks, {NY #= Y+1},
    parse(T, NY), {append(Line, T, List)}.

parse(Line, Y) --> parse(0, Y, Line), blanks, eos.

parse(_, _, []) --> "\n".
parse(X, Y, List) --> ".", {NX #= X+1}, parse(NX, Y, List).
parse(X, Y, [X-Y|T]) --> "#", {NX #= X+1}, parse(NX, Y, T).

run :-
    input_stream(17, parse(List, 0)),
    part1(List, Ans1),
    write_part1(Ans1),
    part2(List, Ans2),
    write_part2(Ans2).

% neighbours: first attempt was fancy using clpfd to declare ranges per dimension
% then findall coordinates with values in those dimensions using label/1
% went from 60s to 20s using findall where coordinates are member of [Xmin, X, Xmax]
% instead of using clpfd for the 4d case as above
% went to 15s using full written out form below
% went to 11s by _removing_ table neighbours/2 (!)
% went to 8s by also writing out the full form for the 3d case
neighbours(C, Ns) :-
    C = c(X,Y,Z),
    Xm #= X-1, Xp #= X+1,
    Ym #= Y-1, Yp #= Y+1,
    Zm #= Z-1, Zp #= Z+1,
    Ns = [
        c(Xm,Ym,Zm), c(Xm,Ym,Z), c(Xm,Ym,Zp),
        c(Xm,Y,Zm), c(Xm,Y,Z), c(Xm,Y,Zp),
        c(Xm,Yp,Zm), c(Xm,Yp,Z), c(Xm,Yp,Zp),

        c(X,Ym,Zm), c(X,Ym,Z), c(X,Ym,Zp),
        c(X,Y,Zm), c(X,Y,Zp),
        c(X,Yp,Zm), c(X,Yp,Z), c(X,Yp,Zp),

        c(Xp,Ym,Zm), c(Xp,Ym,Z), c(Xp,Ym,Zp),
        c(Xp,Y,Zm), c(Xp,Y,Z), c(Xp,Y,Zp),
        c(Xp,Yp,Zm), c(Xp,Yp,Z), c(Xp,Yp,Zp)
    ].

neighbours(C, Ns) :-
    C = c(X,Y,Z,W),
    Xm #= X-1, Xp #= X+1,
    Ym #= Y-1, Yp #= Y+1,
    Zm #= Z-1, Zp #= Z+1,
    Wm #= W-1, Wp #= W+1,
    Ns = [
        c(Xm,Ym,Zm,Wm), c(Xm,Ym,Zm,W), c(Xm,Ym,Zm,Wp),
        c(Xm,Ym,Z,Wm), c(Xm,Ym,Z,W), c(Xm,Ym,Z,Wp),
        c(Xm,Ym,Zp,Wm), c(Xm,Ym,Zp,W), c(Xm,Ym,Zp,Wp),

        c(Xm,Y,Zm,Wm), c(Xm,Y,Zm,W), c(Xm,Y,Zm,Wp),
        c(Xm,Y,Z,Wm), c(Xm,Y,Z,W), c(Xm,Y,Z,Wp),
        c(Xm,Y,Zp,Wm), c(Xm,Y,Zp,W), c(Xm,Y,Zp,Wp),

        c(Xm,Yp,Zm,Wm), c(Xm,Yp,Zm,W), c(Xm,Yp,Zm,Wp),
        c(Xm,Yp,Z,Wm), c(Xm,Yp,Z,W), c(Xm,Yp,Z,Wp),
        c(Xm,Yp,Zp,Wm), c(Xm,Yp,Zp,W), c(Xm,Yp,Zp,Wp),

        c(X,Ym,Zm,Wm), c(X,Ym,Zm,W), c(X,Ym,Zm,Wp),
        c(X,Ym,Z,Wm), c(X,Ym,Z,W), c(X,Ym,Z,Wp),
        c(X,Ym,Zp,Wm), c(X,Ym,Zp,W), c(X,Ym,Zp,Wp),

        c(X,Y,Zm,Wm), c(X,Y,Zm,W), c(X,Y,Zm,Wp),
        c(X,Y,Z,Wm), c(X,Y,Z,Wp),
        c(X,Y,Zp,Wm), c(X,Y,Zp,W), c(X,Y,Zp,Wp),

        c(X,Yp,Zm,Wm), c(X,Yp,Zm,W), c(X,Yp,Zm,Wp),
        c(X,Yp,Z,Wm), c(X,Yp,Z,W), c(X,Yp,Z,Wp),
        c(X,Yp,Zp,Wm), c(X,Yp,Zp,W), c(X,Yp,Zp,Wp),

        c(Xp,Ym,Zm,Wm), c(Xp,Ym,Zm,W), c(Xp,Ym,Zm,Wp),
        c(Xp,Ym,Z,Wm), c(Xp,Ym,Z,W), c(Xp,Ym,Z,Wp),
        c(Xp,Ym,Zp,Wm), c(Xp,Ym,Zp,W), c(Xp,Ym,Zp,Wp),

        c(Xp,Y,Zm,Wm), c(Xp,Y,Zm,W), c(Xp,Y,Zm,Wp),
        c(Xp,Y,Z,Wm), c(Xp,Y,Z,W), c(Xp,Y,Z,Wp),
        c(Xp,Y,Zp,Wm), c(Xp,Y,Zp,W), c(Xp,Y,Zp,Wp),

        c(Xp,Yp,Zm,Wm), c(Xp,Yp,Zm,W), c(Xp,Yp,Zm,Wp),
        c(Xp,Yp,Z,Wm), c(Xp,Yp,Z,W), c(Xp,Yp,Z,Wp),
        c(Xp,Yp,Zp,Wm), c(Xp,Yp,Zp,W), c(Xp,Yp,Zp,Wp)
    ].

