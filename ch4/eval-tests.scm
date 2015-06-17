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
(test 1 1)
(test "a" "a")

; quote
(test (list 'quote 'a) 'a)

; test


; simple operators: and, or
(test (list 'and 1 2) 2)
(test (list 'and 'false 2) false)
(test (list 'and 1 'false) false)
(test (list 'and 'false 'false) false)
(test (list 'or 'true 'true) true)
(test (list 'or 'false 'true) true)
(test (list 'or 'true 'false) true)
(test (list 'or 'false 'false) false)

; if
(test (list 'if 'true 1 2) 1)
(test (list 'if false 1 2) 2)
(test (list 'if (list 'and 'true 'true) 1 2) 1) ; compound predicates
(test (list 'if (list 'and 'true 'false) 1 2) 2)
(test (list 'if (list 'and 'true 'true) (list 'and 1 2) 3) 2) ; compound consequents
(test (list 'if (list 'and 'true 'false) 1 (list 'and 2 3)) 3)

;begin -> evals to last expression
(test '(begin 1 2) 2)
(test '(begin (and 1 2) (or 3 4)) 3)

; cond -- need to work on!
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
; (test '(cond
;         (true 1)
;         (("hello" "goodbye") => car)
;         (else '3))
;       1)

; (test '(cond
;         (false 1)
;         (("hello" "goodbye") => car)
;         (else '3))
;       "hello")

; (test '(cond
;         (false 1)
;         ((and (1 2) false) => car)
;         (else 3))
;       3)

; Definition
(test '(begin (define a 1) a) 1)
(test '(begin (define b 2) b) 2)
(test '(+ a b) 3)
(test '(begin (set! a 3) a) 3)
(test '(begin (set! b 4) b) 4)
(test '(+ a b) 7)
(test '(begin (set! a (+ 5 5)) a) 10)

'ok

