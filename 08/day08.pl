:- ['../lib/io.pl'].

exec(nop, _, 1, 0).
exec(acc, N, 1, N).
exec(jmp, N, N, 0).

part1(Program, Ans) :-
    run_program(Program, -1, 0, 0, Ans, [], false).

mod(nop, jmp).
mod(jmp, nop).
mod(acc, acc).

run_program(Program, Mod, Ptr, OldAcc, Acc, Seen, Terminated) :-
    [Op, N] = Program.Ptr,
    ( Ptr = Mod -> mod(Op, ModOp); Op=ModOp),
    exec(ModOp, N, NPtr, NAcc),
    NewPtr #= Ptr + NPtr,
    NewAcc #= OldAcc + NAcc,
    (
        intersection([NewPtr], Seen, [NewPtr])
    ->
        Terminated = false,
        Acc #= NewAcc
    ;
        (
            get_dict(NewPtr, Program, _)
        ->
            NewSeen = [NewPtr|Seen],
            run_program(Program, Mod, NewPtr, NewAcc, Acc, NewSeen, Terminated)
        ;
            Terminated = true,
            Acc #= NewAcc
        )
    ).

nop_or_jmp(Program, I) :-
    Program.I = [Op, _],
    member(Op, [nop, jmp]).

check_terminates([H|T], Program, Ans) :-
    run_program(Program, H, 0, 0, X, [], Terminated),
    ( Terminated -> Ans #= X ; check_terminates(T, Program, Ans)).

part2(Program, Ans) :-
    numlist(0, Program.len, Nums),
    include(nop_or_jmp(Program), Nums, List),
    check_terminates(List, Program, Ans).

parse(LineNum, [Instr|T]) --> parse_line(LineNum, Instr), "\n",
    {NewLineNum #= LineNum+1}, parse(NewLineNum, T).
parse(LineNum, [Instr]) --> parse_line(LineNum, Instr), blanks, eos.

parse_line(I,I-[S,N]) --> string_without(" ", C), " ", integer(N), {atom_codes(S, C)}.

run :-
    input_stream(8, parse(0, List)),
    dict_create(Dict, program, List),
    dict_keys(Dict, [_|Keys1Based]),
    length(Keys1Based, N),
    Program = Dict.put(len, N),
    part1(Program, Ans1),
    write_part1(Ans1),
    part2(Program, Ans2),
    write_part2(Ans2).
