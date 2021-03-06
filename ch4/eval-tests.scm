;; Testing Utils
(define (log msg)
  (newline)
  (display msg))

(define (test expression expected)
  (let ((result (eval expression the-global-environment)))
    (if (equal? result expected)
      (log (list "pass" expression))
      (begin
        (log (list "**FAIL**" expression))
        (log (list "  Expected: " expected))
        (log (list "  Result:   " result))))))

; primitives
(log "***PRIMITIVES***")
(test 1 1)
(test "a" "a")

; quote
(log "***QUOTE***")
(test (list 'quote 'a) 'a)

; simple operators: and, or
(log "***AND***")
(test (list 'and) true)
(test (list 'and 'false) false)
(test (list 'and 1) 1)
(test (list 'and 1 2) 2)
(test (list 'and 'false 2) false)
(test (list 'and 1 'false) false)
(test (list 'and 'false 'false) false)
(test (list 'and 1 2 3) 3)
(test (list 'and 1 2 'false) false)
(log "***OR***")
(test (list 'or) false)
(test (list 'or 1) 1)
(test (list 'or 1 2) 1)
(test (list 'or 'false 2) 2)
(test (list 'or 1 'false) 1)
(test (list 'or 'false 'false) false)
(test (list 'or 1 2 3) 1)

; if
(log "***IF***")
(test (list 'if 'true 1 2) 1)
(test (list 'if false 1 2) 2)
(test (list 'if (list 'and 'true 'true) 1 2) 1) ; compound predicates
(test (list 'if (list 'and 'true 'false) 1 2) 2)
(test (list 'if (list 'and 'true 'true) (list 'and 1 2) 3) 2) ; compound consequents
(test (list 'if (list 'and 'true 'false) 1 (list 'and 2 3)) 3)

;begin -> evals to last expression
(log "***BEGIN***")
(test '(begin 1 2) 2)
(test '(begin (and 1 2) (or 3 4)) 3)
(test '(begin
        (define a 1)
        (define b 2)
        (+ a b))
      3)
(test '(begin (+ 1 1)) 2) ; single expression

; cond -- need to work on!
(log "***COND***")
(test '(cond (true 1) (else 2)) 1)
(test '(cond (false 1) (else 2)) 2)
(test '(cond ((or true false) 1) (else 2)) 1) ;compound predicates
(test '(cond ((and true false) 1) (else 2)) 2)
(test '(cond (true (or 1 2)) (else (or 3 4))) 1)
(test '(cond
        (false (or 1 2))
        (else (or 3 4)))
      3)

; These work, but haven't implemented => yet
(test '(cond
        (true 1)
        (("hello" "goodbye") => car)
        (else 3))
      1)

(test '(cond
        (false 1)
        ((list "hello" "goodbye") => car)
        (else 3))
      "hello")

;(test '(cond
;        (false 1)
;        ((and (list 1 2) false) => car)
;        (else 3))
;      3)

; Definition
(log "***DEFINITION***")
(test '(begin (define a 1) a) 1) ; normal variable definition
(test '(begin (define b 2) b) 2)
(test '(+ a b) 3)

(test '(begin                    ; sugar for lambda
        (define (add1 n) (+ n 1))
        (add1 1))
      2)

; Assignment
(log "***ASSIGNMENT")
(test '(begin (set! a 3) a) 3)
(test '(begin (set! b 4) b) 4)
(test '(+ a b) 7)
(test '(begin (set! a (+ 5 5)) a) 10) ; can reset a variable

; Lambdas
(log "***LAMBDAS***")
(test '((lambda (x) (+ x x)) 2) 4)
(test '(begin
         (define double (lambda (x) (+ x x)))
         (double 4))
      8)

(log "***LET***")
(test '(let ((a 1)) a) 1)
(test '(let ((a 1) (b 2)) (+ a b)) 3)
(test '(let ((a 1) (b 2)) (+ a b)) 3)
(test '(let ((a 1)) ; nested
        (let ((b 2))
          (+ a b)))
       3)

(test '(let* ((a 1)) a) 1)
(test '(let* ((a 1) (b 2)) (+ a b)) 3)
(test '(let* ((a 1) (b (+ a 1)))  ; b defined in reference to a
            (+ a b))
        3)
(test '(let* ((a 1)
              (b (+ a 1))
              (c (+ b 1)))
            (+ a b c))
        6)

(test    ; named let
  '(begin
    (define (fib n)
      (let fib-iter ((a 1)
                     (b 0)
                     (count n))
        (if (= count 0)
          b
          (fib-iter (+ a b) a (- count 1)))))
    (fib 6))
  8)



(log "***LOOPS***")
(log "**While**")
(test
  '(let ((a 0))
    (while (< a 10) (set! a (+ a 1)))
    a)
  10)

(test
  '(let ((a 0))
    (while false (set! a (+ a 1)))
    a)
  0)

(log "**Until**")
(test
  '(let ((a 0))
    (until (> a 10) (set! a (+ a 1)))
    a)
  11)

(test
  '(let ((a 0))
    (until true (set! a (+ a 1)))
    a)
  0)

(log "**Do**")
(test
  '(let ((a 0))
    (do (< a 10) (set! a (+ a 1)))
    a)
  10)

(test
  '(let ((a 0))
    (do false (set! a (+ a 1)))
    a)
  1) ; runs once always

(log "**Nested Defines**")
(test
  '(begin
    (define (three)
      (define a 1)
      (define b 2)
      (+ a b))
    (three))
  3)

(test
  '(begin
    (define (odd? n)
      (if (= n 0)
        false
        (even? (- n 1))))
    (define (even? n)
      (if (= n 0)
        true
        (odd? (- n 1))))
    (odd? 5))
  true)
'ok