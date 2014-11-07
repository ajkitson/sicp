; Here is an alternateive procedural representation of pairs. For this representation, verify that (car (cons x y)) yields x for any
; objects x and y. 

(define (cons x y)
	(lambda (m) (m x y)))

(define (car z)
	(z (lambda (p q) p)))

; What is the corresponding definition of cdr? (Hint: to verify that this works, make use of the substitution model of section 1.1.5)
; =====
; This is neat. Cons basically creates a closure, returning a procedure you can pass to car and cdr to access the closure variable
; you want.
; Here's the cdr implementation:
(define (cdr z)
	(z (lambda (p q) q)))

; in action:
1 ]=> (define p (cons 123 456))
;Value: p

1 ]=> (car p)
;Value: 123

1 ]=> (cdr p)
;Value: 456
