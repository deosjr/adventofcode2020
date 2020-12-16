:- ['../lib/io.pl'].

% assumes all input is positive
join_domains(Domains, AllowedDomain) :-
    foldl([X,Y,Z]>>(
        Z = Y\/X
    ), Domains, -1, AllowedDomain).

part1(Fields, Tickets, Ans) :-
    maplist([[_,D],X]>>(X=D), Fields, Domains),
    join_domains(Domains, AllowedDomain),
    maplist({AllowedDomain}/[List, Sum]>>(
        exclude([X]>>(X in AllowedDomain), List, Inv),
        sum(Inv, #=, Sum)
    ), Tickets, Invalid),
    sum(Invalid, #=, Ans).

part2(Fields, Ticket, Tickets, Ans) :-
    maplist([[_,D],X]>>(X=D), Fields, Domains),
    join_domains(Domains, AllowedDomain),
    include([X]>>(
        forall(member(M, X), (
            M in AllowedDomain
        ))
    ), Tickets, ValidTickets),

    length(Fields, N),
    length(Values, N),
    maplist(=([]), Values),
    foldl([X,Y,Z]>>(
        maplist([A,B,C]>>(C = [A|B]), X, Y, Z)
    ), [Ticket|ValidTickets], Values, AllValues),

    maplist({Fields}/[AV,List]>>(
        findall(M, (nth1(M, Fields, [_,FD]), AV ins FD), List)
    ), AllValues, AllValidFields),

    find_valid(AllValidFields, [], ValidConfig),
    numlist(1, 6, DepartureFields),
    maplist({ValidConfig, Ticket}/[X,Y]>>(
        member(I-X, ValidConfig),
        nth1(I, Ticket, Y)
    ), DepartureFields, TicketValues),
    foldl([X,Y,Z]>>(Z #= X * Y), TicketValues, 1, Ans).

find_valid(Configs, Found, Valid) :-
    findall(M-F, nth1(M, Configs, [F]), List),
    ( List = [] -> Valid = Found ; 
        append(List, Found, NewFound),
        maplist({NewFound}/[X,Y]>>(
            exclude([Z]>>(member(_-Z, NewFound)), X, Y)
        ), Configs, Filtered),
        find_valid(Filtered, NewFound, Valid)
    ).
    
parse(Fields, Ticket, Tickets) --> 
    parse_fields(Fields), "your ticket:\n", parse_ticket(Ticket),
    "\nnearby tickets:\n", parse_tickets(Tickets).

parse_fields([]) --> "\n".
parse_fields([[Str,R1\/R2]|T]) -->
    parse_field(Name, R1, R2), "\n", parse_fields(T), {string_codes(Str, Name)}.
parse_field(Fieldname, R1, R2) -->
    string_without(":", Fieldname), ": ", parse_range(R1), " or ", parse_range(R2).
parse_range(From..To) -->
    integer(From), "-", integer(To).

parse_ticket([]) --> "\n".
parse_ticket([H|T]) --> integer(H), parse_ticket(T).
parse_ticket([H|T]) --> ",", integer(H), parse_ticket(T).

parse_tickets([]) --> blanks, eos.
parse_tickets([H|T]) --> parse_ticket(H), parse_tickets(T).

run :-
    input_stream(16, parse(Fields, Ticket, Tickets)),
    part1(Fields, Tickets, Ans1),
    write_part1(Ans1),
    part2(Fields, Ticket, Tickets, Ans2),
    write_part2(Ans2).
