:- ['../lib/io.pl'].

:- dynamic instr/3.

exec("nop", _, 1, 0).
exec("acc", N, 1, N).
exec("jmp", N, N, 0).

run_program(Ptr, OldAcc, Acc, Seen) :-
    instr(Ptr, Instr, N),
    exec(Instr, N, NPtr, NAcc),
    NewPtr #= Ptr + NPtr,
    NewAcc #= OldAcc + NAcc,
    (
        member(NewPtr, Seen)
    ->
        Acc #= NewAcc
    ;
        NewSeen = [NewPtr|Seen],
        run_program(NewPtr, NewAcc, Acc, NewSeen)
    ).

part1(Ans) :-
    run_program(0, 0, Ans, []).

mod("nop", "jmp").
mod("jmp", "nop").
mod("acc", "acc").

% this would be faster if we assert run state, but good enough for now
run_program_modified(Mod, Ptr, OldAcc, Acc, Seen, Terminated) :-
    instr(Ptr, Instr, N),
    ( Ptr = Mod -> mod(Instr, ModInstr); Instr=ModInstr),
    exec(ModInstr, N, NPtr, NAcc),
    NewPtr #= Ptr + NPtr,
    NewAcc #= OldAcc + NAcc,
    (
        member(NewPtr, Seen)
    ->
        Terminated = false,
        Acc #= NewAcc
    ;
        (
            not(instr(NewPtr,_,_))
        ->
            Terminated = true,
            Acc #= NewAcc
        ;
            NewSeen = [NewPtr|Seen],
            run_program_modified(Mod, NewPtr, NewAcc, Acc, NewSeen, Terminated)
        )
    ).

part2(Ans) :-
    findall(I, (instr(I, Instr, _), member(Instr, ["nop","jmp"])), List),
    maplist([X,Y]>>(
        run_program_modified(X, 0, 0, Z, [], Terminated), Y=Z-Terminated
    ), List, AnsList),
    member(Ans-true, AnsList).

parse(LineNum) --> parse_line(LineNum), "\n", {NewLineNum #= LineNum+1}, parse(NewLineNum).
parse(LineNum) --> parse_line(LineNum), blanks, eos.

parse_line(I) --> string_without(" ", C), " ", integer(N),
    {string_codes(S, C), assertz(instr(I, S, N))}.

run :-
    input_stream(8, parse(0)),
    part1(Ans1),
    write_part1(Ans1),
    part2(Ans2),
    write_part2(Ans2).
