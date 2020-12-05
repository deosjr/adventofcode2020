;; gitignored, contains paths to files from 
;; https://github.com/michaelballantyne/faster-miniKanren
;; namely mk-vicare.scm, mk.scm and numbers.scm
(load "lib/hardcodedpath.scm")

;; anonymous vars in minikanren
(define (_) 
  (vector unbound (new-scope) (random 10000000)))

(define (membero x y)
  (fresh (a d)
  (== y `(,a . ,d))
  (conde
    [(== x a)]
    [(membero x d)])))

;; faster-minikanren dropped disj in favor of the conde macro directly
;; i need disj+ at least in order to implement unroll
(define (disj g1 g2)
    (lambda (st) 
            (mplus* (g1 st) (g2 st))))

(define (disj+ goals) 
    (let ((gcar (car goals)) (gcdr (cdr goals)))
      (cond
        ((eq? gcdr '()) gcar)
        (else (lambda (st) ((disj gcar (disj+ gcdr)) st))))))

;; faster membero when checking in the same list multiple times
;; rewrites the membero to a disjunction of member equals checks
(define (membero-unrolled ylist)
  (lambda (x)
   (lambda (st) 
     (let ((st (state-with-scope st nonlocal-scope))) (
    (disj+ (map (lambda (f) (f x)) (map (lambda (y) (lambda (z) (== z y))) ylist)))
    st )))))

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

(define string-replace
  (lambda (s c r)
    (let ((n (string-length s)))
      (do ((i 0 (+ i 1)))
          ((= i n))
          (if (char=? (string-ref s i) c) (string-set! s i r)))) s ))

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
