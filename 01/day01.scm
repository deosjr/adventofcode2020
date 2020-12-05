#! /usr/bin scheme --script
(load "lib/lib.scm")

(define input (read-entire-file "01/day01.input"))

(define input-parsed (map (lambda (x) (build-num (string->number x))) (str-split input #\newline)))

(define n2020 (build-num 2020))
(define n1010 (build-num 1010))

(define member-of-input (membero-unrolled input-parsed))

;; we only want one answer since we get the answer twice: once for x and once for y
(define part1 (run 1 (q)
    (fresh (x y) 
        (member-of-input x)
        (minuso n2020 x y)
        (member-of-input y)
        (== q `(,x ,y)))))
        ;;(*o x y q))))

;; multiplication using *o is expensive so take it outside of miniKanren
(define ans (fold-left * 1 (map parse-num (car part1))))
(printf "Part 1: ~w\n" ans)

;; using the observation that if x+y+z = 2020,
;; at least 2 of x,y,z need to be < 2020/2

(define filtered (run* (q)
    (member-of-input q)
    (<o q n1010)))

(define member-of-filtered (membero-unrolled filtered))

(define part2 (run 1 (q)
    (fresh (x y z n) 
        (member-of-filtered x)
        (=/= x y)
        (member-of-filtered y)
        (minuso n2020 x n)
        (minuso n y z)
        (member-of-input z)
        (== q `(,x ,y ,z)))))

(define ans (fold-left * 1 (map parse-num (car part2))))
(printf "Part 2: ~w\n" ans)
