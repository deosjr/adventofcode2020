:- ['../lib/io.pl'].

exec(nop, _, 1, 0).
exec(acc, N, 1, N).
exec(jmp, N, N, 0).

part1(Program, Ans, Seen) :-
    run_program(Program, 0, 0, Ans, [], Seen, false).

run_program(Program, Ptr, OldAcc, Acc, SeenSoFar, Seen, Terminated) :-
    [Op, N] = Program.Ptr,
    exec(Op, N, NPtr, NAcc),
    NewPtr #= Ptr + NPtr,
    NewAcc #= OldAcc + NAcc,
    (
        intersection([NewPtr], SeenSoFar, [NewPtr])
    ->
        Terminated = false,
        Seen = SeenSoFar,
        Acc #= NewAcc
    ;
        (
            get_dict(NewPtr, Program, _)
        ->
            NewSeen = [NewPtr|SeenSoFar],
            run_program(Program, NewPtr, NewAcc, Acc, NewSeen, Seen, Terminated)
        ;
            Terminated = true,
            Seen = SeenSoFar,
            Acc #= NewAcc
        )
    ).

% For my input instr 377 is corrupt
% TODO: find the corrupt ptr index
find_corrupted(Program, Seen, Corrupted) :-
    numlist(0, Program.len, List),
    reverse(List, RevList),
    %TODO
    Corrupted #= 377.

% old part 2: brute force search through programs with one instruction repaired
% new part 2: first find the instr that is corrupted, repair it, then run once
part2(Program, SeenInP1, Ans) :-
    find_corrupted(Program, SeenInP1, Corrupted),
    % dancing around dict lib particulars:
    % using Corrupted as key in select_dict gives syntax error: key_expected
    dict_create(OldInstr, program, [Corrupted-[Name, N]]),
    select_dict(OldInstr, Program, _), %Test :< Program,
    (Name=jmp -> NewName=nop ; NewName=jmp),
    % same dance..
    dict_create(NewInstr, program, [Corrupted-[NewName, N]]),
    NewProgram = Program.put(NewInstr),
    run_program(NewProgram, 0, 0, Ans, [], _, true).

parse(LineNum, [Instr|T]) --> parse_line(LineNum, Instr), "\n",
    {NewLineNum #= LineNum+1}, parse(NewLineNum, T).
parse(LineNum, [Instr]) --> parse_line(LineNum, Instr), blanks, eos.

parse_line(I,I-[S,N]) --> string_without(" ", C), " ", integer(N), {atom_codes(S, C)}.

list_to_program(List, Program) :-
    dict_create(Dict, program, List),
    dict_keys(Dict, [_|Keys1Based]),
    length(Keys1Based, N),
    Program = Dict.put(len, N).

run :-
    input_stream(8, parse(0, List)),
    list_to_program(List, Program),
    part1(Program, Ans1, SeenInP1),
    write_part1(Ans1),
    part2(Program, SeenInP1, Ans2),
    write_part2(Ans2).
