; Show that the golden ratio phi is a fixed point of the transformatin x -> 1 + 1/x, and use this fact to compute phi by means
; of the fixed-point procedure.
; =====
; phi is a fixed point of x -> 1 + 1/x IFF phi = 1 + 1/phi. Let's show that it is.
phi = 1 + 1/phi
phi^2 = (1 + 1/phi)phi = phi + 1

; That phi^2 = phi + 1 is one of the prorperties of phi we used to solve 1.13. Let's show how that works. We'll show that phi^2
; reduced to phi + 1
; First we expand phi^2 using the definition of phi:
((1 + sqrt(5)) / 2)((1 + sqrt(5)) / 2)
; consolidate denominators:
(1 + sqrt(5))(1 + sqrt(5)) / 2
; combine:
(6 + 2sqrt(5)) / 2
; reduce:
(3 + sqrt(5)) / 2
; and separate out 1 (2/2):
1 + (1 + sqrt(5)) / 2
; There we go. phi is a fixed point of x -> 1 + 1/x
; Now let's compute phi with our fixed-point procedure. 

(define (fixed-point f first-guess)
	(define (close-enough? v1 v2)
		(< (abs (- v1 v2)) 0.00001))
	(define (try guess)
		(let ((next (f guess)))
			(if (close-enough? guess next)
				next
				(try next))))
	(try first-guess))

1 ]=> (fixed-point (lambda (x) (+ 1 (/ 1.0 x))) 1.0)
;Value: 1.6180327868852458

; That's what we're looking for!
