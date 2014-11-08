; Alyssa's program is incomplete because she has not specified the implementation of the interval abastraction. Here is a definition of
; the interval constructor:

(define (make-interval a b)
	(cons a b))

; Define selectors upper-bound and lower-bound to complete the implementation.
; ===
; Pretty straightforward:
(define (upper-bound i)
	(cdr i))

(define (lower-bound i)
	(car i))