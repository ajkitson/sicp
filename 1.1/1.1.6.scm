; Alyssa P. Hacker desont' see why if needs to be a special form. Alyssa's friend Eva Lu Ator claims
; this can indeed be done, and she defines a new version of if:
(define (new-if predicate then-clause else-clause)
	(cond (predicate then-clause)
		(else else-clause)))

; Eva demonstrates the program for Alyssa:
(new-if (= 2 3) 0 5)
; => 5

(new-if (= 1 1) 0 5))
; => 0

; Delighted, Alyssa uses new-if to rewrite the square-root program:
(define (sqrt-iter guess x)
	(new-if (good-enough? guess x) 
		guess
		(sqrt-iter (improve guess x)
			x)))

; What happends when Alyssa attempts to use this to compute square roots? Explain.

; What happens? It never stops. Or rather, it only stops when it errors out. IF is a special form in that only one of 
; the procedures in the then and else clauses is evaluated, depeending on the predicate evaluation. However, given 
; that Lisp interpreters use applicative evaluation, both the then and else procedures are evaluated when passed 
; to new-if. In this case, the else-clause calls sqrt-iter again, which has another else-clause that runs sqrt-iter, 
; on ad infinitum.
;
; That's my guess anyway. Let's try it out.
; Full definition with real IF
(define (sqrt-iter guess x) 
	(if (good-enough? guess x)
		guess
		(sqrt-iter (improve guess x) 
					x)))

(define (improve guess x)
	(average guess (/ x guess)))

(define (average x y) 
	(/ (+ x y) 2))

(define (good-enough? guess x)
	(< (abs (- (square guess) x)) .001))

(define (square x) (* x x))

(define (sqrt x)
	(sqrt-iter 1.0 x))

1 ]=> (sqrt 9)
;Value: 3.00009155413138

1 ]=> (sqrt 144)
;Value: 12.000000012408687


; Now with new-if: (supporting procedures same as above)
(define (sqrt-iter guess x) 
	(new-if (good-enough? guess x)
		guess
		(sqrt-iter (improve guess x) 
					x)))

(define (new-if predicate then-clause else-clause)
	(cond (predicate then-clause)
		(else else-clause)))

; Sure enough: 
1 ]=> (sqrt 9)
;Aborting!: maximum recursion depth exceeded

1 ]=> (sqrt 144)
;Aborting!: maximum recursion depth exceeded

