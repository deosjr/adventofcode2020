#! /usr/bin scheme --script
(load "lib/lib.scm")

(define input (read-entire-file "05/day05.input"))

(define (to-binary s)
    (parse-num (reverse
    (map (lambda (x) (string->number (string x)))
    (string->list
    (string-replace (string-replace (string-replace
    (string-replace s #\R #\1) #\B #\1) #\L #\0) #\F #\0))))))

(define input-parsed (map (lambda (x) (to-binary x)) (str-split input #\newline)))

(define ans1 (apply max input-parsed))
(printf "Part 1: ~w\n" ans1)

(define (find-seat prev l ans)
    (fresh (a d next)
        (== l `(,a . ,d))
        (pluso prev (build-num 1) next)
        (conde
            [(== next a) (find-seat next d ans)]
            [(=/= next a) (== ans next)])))

(define sorted (map build-num (sort < input-parsed)))

(define ans2 (run* (q)
    (find-seat (car sorted) (cdr sorted) q)))

(printf "Part 2: ~w\n" (parse-num (car ans2)))
