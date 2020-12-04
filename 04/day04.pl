:- ['../lib/io.pl'].

passport_keyvalue("byr", Value, passport(Value,_,_,_,_,_,_,_)).
passport_keyvalue("iyr", Value, passport(_,Value,_,_,_,_,_,_)).
passport_keyvalue("eyr", Value, passport(_,_,Value,_,_,_,_,_)).
passport_keyvalue("hgt", Value, passport(_,_,_,Value,_,_,_,_)).
passport_keyvalue("hcl", Value, passport(_,_,_,_,Value,_,_,_)).
passport_keyvalue("ecl", Value, passport(_,_,_,_,_,Value,_,_)).
passport_keyvalue("pid", Value, passport(_,_,_,_,_,_,Value,_)).
passport_keyvalue("cid", Value, passport(_,_,_,_,_,_,_,Value)).

parse_passport(List, Passport) :-
    foreach(member(Key-Value, List), passport_keyvalue(Key, Value, Passport)).

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

parse([Passport]) --> parse_passport(Passport), blanks, eos.
parse([H|T]) --> parse_passport(H), "\n\n", parse(T).

parse_passport([E]) --> parse_entry(E).
parse_passport([E|T]) --> parse_entry(E), (" ";"\n"), parse_passport(T).

parse_entry(Key-Value) --> string_without(" \n:", K), ":", string_without(" \n", V),
    {string_codes(Key, K), string_codes(Value, V)}.

run :-
    input_stream(4, parse(Lines)),
    maplist(parse_passport, Lines, Passports),
    part1(Passports, Ans1),
    write_part1(Ans1),
    part2(Passports, Ans2),
    write_part2(Ans2).
