;; gitignored, contains paths to files from 
;; https://github.com/michaelballantyne/faster-miniKanren
;; namely mk-vicare.scm, mk.scm and numbers.scm
(load "lib/hardcodedpath.scm")

(define (_) 
  (vector unbound (new-scope) (random 10000000)))

(define (membero x y)
  (fresh (a d)
  (== y `(,a . ,d))
  (conde
    [(== x a)]
    ;;[(=/= x a) (membero x d)]
    [(membero x d)]
    )))

(define (read-file-oneline filename)
    (get-line (open-input-file filename)))

(define (read-entire-file filename)
    (get-string-all (open-input-file filename)))

;; https://gist.github.com/matthewp/2324447
;; also whyyyy does chez scheme not have this built in?!?!
(define (str-split str ch)
  (let ((len (string-length str)))
    (letrec
      ((split
        (lambda (a b)
          (cond
            ((>= b len) (if (= a b) '() (cons (substring str a b) '())))
              ((char=? ch (string-ref str b)) (if (= a b)
                (split (+ 1 a) (+ 1 b))
                  (cons (substring str a b) (split b b))))
                (else (split a (+ 1 b)))))))
                  (split 0 0))))

;; my own. trims one char to the right if match
(define (trim-right str ch)
    (let ((len (string-length str)))
        (cond
        [(char=? ch (string-ref str (- len 1))) (substring str 0 (- len 1))]
        [else str])))

;; build-num from numbers.scm transforms integer x to binary representation list
;; parse-num transforms it back
(define (parse-num n) (parse-num* n 0))

(define (parse-num* n i)
    (cond
        [(null? n) 0]
        [else (cond
            [(eq? (car n) 0) (parse-num* (cdr n) (+ 1 i))]
            [(eq? (car n) 1) (+ (expt 2 i) (parse-num* (cdr n) (+ 1 i)))])]))
