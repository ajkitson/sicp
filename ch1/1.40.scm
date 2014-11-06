; Define a procedure cubic that can be used together with the newtons-method procedure in expressions of the form
; (newtons-method (cubic a b c) 1) to approximate zeros of teh cubic x^3 + ax^2 + bx + c.
; =====
; This should be pretty straightforward, just have cubic return a procedure that uses the specific values a, b, and c.
; First, let's pull in fixed-point and newtons-method:
(define (fixed-point f first-guess)
	(define (close-enough? v1 v2)
		(< (abs (- v1 v2)) 0.00001))
	(define (try guess)
		(newline)
		(display guess)  
		(let ((next (f guess)))
			(if (close-enough? guess next)
				next
				(try next))))
	(try first-guess))

(define (newtons-method g guess)
	(define dx 0.00001)
	(define (deriv g)
		(lambda (x)
			(/ (- (g (+ x dx)) (g x)) 
				dx)))
	(define (newton-transform g)
		(lambda (x)
			(- x (/ (g x) ((deriv g) x)))))
	(fixed-point (newton-transform g) guess))

; And new we'll define cubic:
(define (cubic a b c)
	(lambda (x)
		(+ ( * x x x)
			(* a (* x x))
			(* b x)
			c)))