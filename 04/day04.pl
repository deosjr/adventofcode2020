:- use_module(library(clpfd)).
:- use_module(library(dcg/basics)).

:- ['../lib/io.pl'].

parse_entry(Passport, Entry) :-
    string_codes(EntryStr, Entry),
    split_string(EntryStr, ":", "", [Key, Value]),
    passport_keyvalue(Key, Value, Passport).
    
passport_keyvalue("byr", Value, passport(Value,_,_,_,_,_,_,_)).
passport_keyvalue("iyr", Value, passport(_,Value,_,_,_,_,_,_)).
passport_keyvalue("eyr", Value, passport(_,_,Value,_,_,_,_,_)).
passport_keyvalue("hgt", Value, passport(_,_,_,Value,_,_,_,_)).
passport_keyvalue("hcl", Value, passport(_,_,_,_,Value,_,_,_)).
passport_keyvalue("ecl", Value, passport(_,_,_,_,_,Value,_,_)).
passport_keyvalue("pid", Value, passport(_,_,_,_,_,_,Value,_)).
passport_keyvalue("cid", Value, passport(_,_,_,_,_,_,_,Value)).

parse_passport(List, Passport) :-
    foreach(member(Entry, List), parse_entry(Passport, Entry)).

valid1(Passport) :-
    Passport =.. [passport|Args],
    foldl([X,Y,Z]>>(ground(X) -> Z#=Y+1 ; Z#=Y), Args, 0, SumGround),
    passport_keyvalue("cid", Cid, Passport),
    (SumGround #= 8 ; (SumGround #= 7, var(Cid))).

part1(Passports, Ans) :-
    foldl([X,Y,Z]>>(valid1(X)->Z#=Y+1;Z#=Y), Passports, 0, Ans).

valid_byr(Byr) :-
    number_string(Nbyr, Byr), Nbyr in 1920..2002.

valid_iyr(Iyr) :-
    number_string(Niyr, Iyr), Niyr in 2010..2020.

valid_eyr(Eyr) :-
    number_string(Neyr, Eyr), Neyr in 2020..2030.

valid_hgt(Hgt) :-
    sub_string(Hgt, Before, 2, 0, Unit),
    sub_string(Hgt, 0, Before, 2, HgtNum),
    number_string(Nhgt, HgtNum),
    (
        Unit = "cm", Nhgt in 150..193
    ;
        Unit = "in", Nhgt in 59..76
    ).
    
valid_hcl(Hcl) :-
    string_length(Hcl, 7),
    sub_string(Hcl, 0, 1, 6, "#"),
    sub_string(Hcl, 1, 6, 0, HclNum),
    string_concat("0x", HclNum, Hex),
    number_string(_, Hex).

valid_ecl(Ecl) :-
    member(Ecl,["amb","blu","brn","gry","grn","hzl","oth"]).

valid_pid(Pid) :-
    number_string(_, Pid), string_length(Pid, 9).

valid2(Passport) :-
    valid1(Passport),
    Passport = passport(Byr,Iyr,Eyr,Hgt,Hcl,Ecl,Pid,_),
    valid_byr(Byr),
    valid_iyr(Iyr),
    valid_eyr(Eyr),
    valid_hgt(Hgt),
    valid_hcl(Hcl),
    valid_ecl(Ecl),
    valid_pid(Pid).

part2(Passports, Ans) :-
    foldl([X,Y,Z]>>(valid2(X)->Z#=Y+1;Z#=Y), Passports, 0, Ans).

concat_passports(Line, SoFar, Next) :-
    (
        Line = ""
    ->
        Next = [[]|SoFar]
    ;
        SoFar = [H|T],
        split_string(Line, " ", "", Split),
        append(H,Split,NewLine),
        Next = [NewLine|T]
    ).

run :-
    read_and_split(4, "\n", Input),
    Input = [L1, L2, L3, L4|T],
    % for some unknown reason, first \n\n is handled differently?!? 
    % not fixed with dcgs (and caused way more mess there too)
    FixedInput = [L1, L2, L3, L4, ""|T],
    foldl(concat_passports, FixedInput, [[]], [[]|RawPassports]),
    maplist(parse_passport, RawPassports, Passports),
    part1(Passports, Ans1),
    write_part1(Ans1),
    part2(Passports, Ans2),
    write_part2(Ans2).
