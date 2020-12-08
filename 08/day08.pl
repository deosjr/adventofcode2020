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

update_set(Old, Elem, New) :-
    union(Old, [Elem], New).

elem_in_set(Elem, Set) :-
    intersection([Elem], Set, [Elem]).

elem_not_in_set(Elem, Set) :-
    intersection([Elem], Set, []).

% loop over instructions from last to first and mark
first_pass(_, [], _, A, A, B, B).
first_pass(Program, [I|T], JmpSeen, WinsOld, WinsNew, PtrsOld, PtrsNew) :-
    Program.I = [Op, N],
    NewJmpSeen = (JmpSeen ; (Op=jmp, I+N #=< Program.last)),
    (
        NewJmpSeen
    ->
        (
            (Op=acc;Op=nop)
        ->
            X #= I+1,
            update_ptr_set(PtrsOld, X, I, PtrsAcc),
            first_pass(Program, T, NewJmpSeen, WinsOld, WinsNew, PtrsAcc, PtrsNew)
        ;
            Op = jmp,
            X #= I + N,
            (
                X #> Program.last
            ->
                update_set(WinsOld, I, WinsAcc),
                first_pass(Program, T, NewJmpSeen, WinsAcc, WinsNew, PtrsOld, PtrsNew)
            ;
                update_ptr_set(PtrsOld, X, I, PtrsAcc),
                first_pass(Program, T, NewJmpSeen, WinsOld, WinsNew, PtrsAcc, PtrsNew)
            )
        )
    ;
        update_set(WinsOld, I, WinsAcc),
        first_pass(Program, T, NewJmpSeen, WinsAcc, WinsNew, PtrsOld, PtrsNew)
    ).

% find all the ptrs that lead to terminating program
winners(Wins, Ptrs, [], New, AllWins) :-
    (
        New = []
    ->
        AllWins = Wins
    ;
        winners(Wins, Ptrs, New, [], AllWins)
    ).

winners(Wins, Ptrs, [W|T], New, AllWins) :-
    (
        get_dict(W, Ptrs, List)
    ->
        union(Wins, List, NewWins),
        union(New, List, NewNew),
        winners(NewWins, Ptrs, T, NewNew, AllWins)
    ;
        winners(Wins, Ptrs, T, New, AllWins)
    ).

% guaranteed to find a single instruction that is corrupted
% we need to find the instr that is visited in part1 and if repaired,
% leads to an instruction that we know leads to termination of the program
identify_corrupted([I|T], Program, Wins, Seen, Corrupted) :-
    (elem_in_set(I, Wins) -> identify_corrupted(T, Program, Wins, Seen, Corrupted);
    (elem_not_in_set(I, Seen) -> identify_corrupted(T, Program, Wins, Seen, Corrupted);
    [Op, N] = Program.I,
    (Op=acc -> identify_corrupted(T, Program, Wins, Seen, Corrupted);
        (
            Op=nop
        ->
            NPtr #= I + N, 
            identify_corrupted_rec(I, NPtr, T, Program, Wins, Seen, Corrupted)
        ;
            Op=jmp,
            NPtr #= I + 1,
            identify_corrupted_rec(I, NPtr, T, Program, Wins, Seen, Corrupted)
        )
    ))).

identify_corrupted_rec(I, NPtr, T, Program, Wins, Seen, Corrupted) :-
    (
        elem_in_set(NPtr, Wins)
    ->
        Corrupted #= I
    ;
        identify_corrupted(T, Program, Wins, Seen, Corrupted)
    ).

find_corrupted(Program, Seen, Corrupted) :-
    numlist(0, Program.last, List),
    reverse(List, RevList),
    first_pass(Program, RevList, false, [], Wins, _{}, Ptrs),
    winners(Wins, Ptrs, Wins, [], AllWins),
    identify_corrupted(List, Program, AllWins, Seen, Corrupted).

% old part 2: brute force search through programs with one instruction repaired
% new part 2: first find the instr that is corrupted, repair it, then run once
% for more explanation, see Go code (this became quite messy in Prolog)
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
    Program = Dict.put(last, N).

run :-
    input_stream(8, parse(0, List)),
    list_to_program(List, Program),
    part1(Program, Ans1, SeenInP1),
    write_part1(Ans1),
    part2(Program, SeenInP1, Ans2),
    write_part2(Ans2).
