:- ['../lib/io.pl'].

exec(nop, _, 1, 0).
exec(acc, N, 1, N).
exec(jmp, N, N, 0).

part1(Program, Seen, Ans) :-
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
            NewPtr #=< Program.last
        ->
            NewSeen = [NewPtr|SeenSoFar],
            run_program(Program, NewPtr, NewAcc, Acc, NewSeen, Seen, Terminated)
        ;
            Terminated = true,
            Seen = SeenSoFar,
            Acc #= NewAcc
        )
    ).

update_ptr_set(Old, Key, Value, New) :-
    (
        get_dict(Key, Old, OldValue)
    ->
        dict_create(Entry, _, [Key-[Value|OldValue]]),
        New = Old.put(Entry)
    ;
        dict_create(Entry, _, [Key-[Value]]),
        New = Old.put(Entry)
    ).

elem_in_set(Set, Elem) :-
    intersection([Elem], Set, [Elem]).

first_pass(Program, I, PtrsOld-WinsOld, PtrsNew-WinsNew) :-
    [Op, N] = Program.I,
    (
        (Op=acc; Op=nop)
    ->
        X #= I+1,
        update_ptr_set(PtrsOld, X, I, PtrsNew),
        WinsOld = WinsNew
    ;
        Op=jmp,
        X #= I + N,
        (
            X #> Program.last
        ->
            union(WinsOld, [I], WinsNew),
            PtrsOld = PtrsNew
        ;
            update_ptr_set(PtrsOld, X, I, PtrsNew),
            WinsOld = WinsNew
        )
    ).

% find all the ptrs that lead to terminating program
winners(Wins, Ptrs, NewlyAdded, AllWins) :-
    foldl([X,Y,Z]>>(get_dict(X, Ptrs, List)->append(List, Y, Z);Z=Y), NewlyAdded, [], New),
    union(Wins, New, NewWins),
    (New=[] -> AllWins=NewWins ; winners(NewWins, Ptrs, New, AllWins) ).

corrupted(Program, Wins, I) :-
    [Op, N] = Program.I,
    ( Op=nop -> NPtr #= I+N ; (Op=jmp, NPtr #= I+1) ),
    elem_in_set(Wins, NPtr).

% guaranteed to find a single instruction that is corrupted
% we need to find the instr that is visited in part1 and if repaired,
% leads to an instruction that we know leads to termination of the program
find_corrupted(Program, Seen, Corrupted) :-
    numlist(0, Program.last, List),
    include([X]>>(get_dict(X, Program, [jmp,N]), X+N #=< Program.last), List, ValidJmps),
    max_list(ValidJmps, HighestValidJmp),
    % TODO: this fails if very last instr is a jmp back into the program?
    StartWins #= HighestValidJmp + 1,
    numlist(StartWins, Program.last, LastWins),
    numlist(0, HighestValidJmp, PtrsToCheck),
    foldl(first_pass(Program), PtrsToCheck, _{}-LastWins, Ptrs-Wins),
    
    winners(Wins, Ptrs, Wins, AllWins),
    include(elem_in_set(Seen), List, SeenInstrs),
    exclude(elem_in_set(AllWins), SeenInstrs, NonWins),
    exclude([X]>>(get_dict(X, Program, [acc,_])), NonWins, Candidates),
    include(corrupted(Program, AllWins), Candidates, [Corrupted]).

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
    dict_keys(Dict, Keys),
    max_list(Keys, N),
    Program = Dict.put(last, N).

run :-
    input_stream(8, parse(0, List)),
    list_to_program(List, Program),
    part1(Program, SeenInP1, Ans1),
    write_part1(Ans1),
    part2(Program, SeenInP1, Ans2),
    write_part2(Ans2).
