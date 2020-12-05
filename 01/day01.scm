#! /usr/bin scheme --script
(load "lib/lib.scm")

(define input (read-entire-file "01/day01.input"))

(define input-parsed (map (lambda (x) (build-num (string->number x))) (str-split input #\newline)))

;; we only want one answer since we get the answer twice: once for x and once for y
(define part1 (run 1 (q)
    (fresh (x y) 
        (membero x input-parsed)
        (minuso (build-num 2020) x y)
        (membero y input-parsed)
        (*o x y q))))

(printf "Part 1: ~w\n" (parse-num (car part1)))

;;(printf "Part 2: ~w\n" )
