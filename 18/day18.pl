:- ['../lib/io.pl'].

value_p1(N, N) :- integer(N).

value_p1(expr(Ops, Nodes), Value) :-
    maplist(value_p1, Nodes, [First|NV]),
    foldl(foldp1, Ops, NV, First, Raw),
    Value #= Raw.

foldp1(Op, Node, Sofar, Out) :-
    Out =.. [Op, Sofar, Node].

part1(Expressions, Ans) :-
    maplist(value_p1, Expressions, Values),
    sum(Values, #=, Ans).

value_p2(N, N) :- integer(N).

value_p2(expr(Ops, Nodes), Value) :-
    maplist(value_p2, Nodes, [First|NV]),
    foldl(foldp2, Ops, NV, [First], Additions),
    foldl(foldtimes, Additions, 1, Value).

foldp2(+, Node, [H|T], [X|T]) :-
    X #= H + Node.

foldp2(*, Node, Sofar, [Node|Sofar]).

foldtimes(X, Y, Z) :- Z #= X * Y.

part2(Expressions, Ans) :-
    maplist(value_p2, Expressions, Values),
    sum(Values, #=, Ans).

parse([Expr]) --> parse_expression(Expr), "\n", eos.
parse([Expr|T]) --> parse_expression(Expr), "\n", parse(T).

parse_expression(expr(Ops, [L|Nodes])) -->
    parse_node(L), parse_right(Ops, Nodes).

parse_node(E) --> "(", parse_expression(E), ")".
parse_node(N) --> integer(N).

parse_right([O|Ops], [E|R]) -->
    parse_operator(O), parse_node(E), parse_right(Ops, R).
parse_right([O], [E]) -->
    parse_operator(O), parse_node(E).

parse_operator(+) --> " + ".
parse_operator(*) --> " * ".

run :-
    input_stream(18, parse(Expressions)),
    part1(Expressions, Ans1),
    write_part1(Ans1),
    part2(Expressions, Ans2),
    write_part2(Ans2).
