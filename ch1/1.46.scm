; Several of the numerical methods described in this chapter are instancess of an extremely geneal computational strategy known as
; iterative improvement. Iterative improvement says that , to compute somethings, we start this an initial guess for the answer, test
; to see if the guess is good enough, and otherwise imporve the guess and continue the process using the improved guess as the new
; guess. Write a procedure iterative-improve that takes two procedures as arguments: a method for telling whehter a guess is good enough
; and a method for improving a guess. Iterative improve should return as its value a procedure that takes a guess as argument and keeps
; improvingthe guess until it is good enough. Rewrite the sqrt procedure of section 1.1.7 and fixed-point procedure of section 1.3.3
; in terms of iterative-improve.
; =====
; 

(define (iterative-improve good-enough? improve)
	(define (iter x)
		(if (good-enough? x)
			x
			(iter (improve x))))
	(lambda (x) (iter x)))


; Now for sqrt:
(define (sqrt x)
	((iterative-improve
		;(lambda (guess) (< (abs (- x (square guess))) 0.001))
		(lambda (guess) (good-enough? x (square guess)))
		(lambda (guess) (/ (+ guess (/ x guess)) 2))) 
	1.0))

1 ]=> (sqrt 144)
;Value: 12.000000012408687

1 ]=> (sqrt 10000)
;Value: 100.00000025490743


; turns out we do a version of this in both fixed point and sqrt....
(define (good-enough? target guess)
	(< (abs (- target guess)) 0.0001))

; And now fixed-point: 
(define (fixed-point f)
	((iterative-improve 
		(lambda (guess) (good-enough? guess (f guess)))
		(lambda (guess) (f guess)))
	1.0))

; Which gets the fixed-point example from pg 69 right:
1 ]=> (fixed-point (lambda (y) (+ (sin y) (cos y))))
;Value: 1.2587758014705526