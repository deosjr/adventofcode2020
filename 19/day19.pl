:- ['../lib/io.pl'].

parse(Rules, Msgs) --> 
    parse_rules(Rules), parse_messages(Msgs).

parse_rules([]) --> "\n".
parse_rules([H|T]) --> parse_rule(H), parse_rules(T).

parse_rule(rule(Head, Body)) -->
    integer(Head), ": ", parse_body(Body).

parse_body([["a"]]) --> "\"a\"\n".
parse_body([["b"]]) --> "\"b\"\n".
parse_body([Sub]) --> parse_subrules(Sub), "\n".
parse_body([S1, S2]) -->
    parse_subrules(S1), " | ", parse_subrules(S2), "\n".

parse_subrules([X]) --> parse_subrule(X).
parse_subrules([X, Y]) --> parse_subrule(X), " ", parse_subrule(Y).
parse_subrule(Sub) --> integer(X), {format(atom(Sub), "rule~d", [X])}.

parse_messages([]) --> blanks, eos.
parse_messages([H|T]) --> string_without("\n", H), "\n", parse_messages(T).

match(Messages, Ans) :-
    include(phrase(rule0), Messages, Valid),
    length(Valid, Ans).

part1(Rules) :-
    forall(member(rule(Head, Body), Rules), (
        format(atom(Name), "rule~d", [Head]),
        forall(member(Sub, Body), (
            ( Sub = [X] -> Pred =.. [-->, Name, X];
              Sub = [X,Y], Pred =.. [-->, Name, (X, Y)]),
            dcg_translate_rule(Pred, DCG),
            assertz(DCG)
        ))
    )).

part2 :-
    dcg_translate_rule((rule8 --> rule42, rule8), NewRule8),
    assertz(NewRule8),
    dcg_translate_rule((rule11 --> rule42, rule11, rule31), NewRule11),
    assertz(NewRule11).

run :-
    input_stream(19, parse(Rules, Messages)),
    part1(Rules),
    match(Messages, Ans1),
    write_part1(Ans1),
    part2,
    match(Messages, Ans2),
    write_part2(Ans2).
