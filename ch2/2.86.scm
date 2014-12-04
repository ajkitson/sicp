; Suppose we want to handle complex numbers whose real parts, imaginary parts, magnitudes, and angles can be either ordinary numbers,
; rational numbers, or other numbers we might wish to add to the system. Describe and implement the changes to the system needed
; to accomodate this. You will have to define operations such as sine and cosine that are generic over ordinary numbers and
; rational numbers.
; =====
; My first reaction was that this would be really hard, but it actually probably won't be. We'll start with our complex number 
; package from 2.5.1 and convert the native arithmetic operators to use the general arithmetic operators we defined in 2.5.1.
; That takes care of almost all the problem. From there, the only challenge is defining sine and cosine, etc. that aren't yet
; part of our general arithmetic package. We'll also have to update the rectangular and polar packages to use the generic 
; operators.

; First we update the packages to use general arithmetic operations. I'm just including the changed parts

; Update the complex package:
(define (install-complex-package)
	;... ommitting stuff that hasn't changed

	; internal procedures -- UPDATE to use general arithmetic operations
	(define (add-complex z1 z2)
		(make-from-real-imag
			(add (real-part z1) (real-part z2))
			(add (imag-part z1) (imag-part z2))))
	(define (sub-complex z1 z2)
		(make-from-real-imag
			(sub (real-part z1) (real-part z2))
			(sub (imag-part z1) (imag-part z2))))
	(define (mul-complex z1 z2)
		(make-from-mag-ang
			(mul (magnitude z1) (magnitude z2))
			(add (angle z1) (angle z2))))
	(define (div-complex z1 z2)
		(make-from-mag-ang
			(/ (magnitude z1) (magnitude z2))
			(- (angle z1) (angle z2))))

	; interface to rest of system
	;....this part hasn't changed, so ommitting

 'done)

; Update polar package (just the updated parts):
(define (install-polar-package)

	; these are update to use general arithmetic package
	(define (real-part z) 
		(mul (magnitude z) (cos-gen (angle z))))
	(define (imag-part z)
		(mul (magnitude z) (sin-gen (angle z))))

	; rest is the same

	'done)

; Update rectangular package (including just updated parts)
(define (install-rectangular-package)
	(define (magnitude z)
		(sqrt-gen 
			(add (square-gen (real-part z))
				(square-gen (imag-part z)))))
	(define (angle z)
		(atan-gen (imag-part z) (real-part z)))

	;rest is the same

	'done)

; Now we had to switch a handful of native arithmetic operations to something more general. We need to define these in a way
; that will work for all types of numbers. Some of these (e.g. square) decompose nicely to existing general arithmetic operations
; Others don't. I'm going to just do some handwaving instead of actually defining these. We'll get the framework in place, though.

(define (square-gen x) (mul x x))
(define (sqrt-gen x) (apply-generic 'sqrt-gen x))
(define (cos-gen a) (apply-generic 'cos-gen a))
(define (atan-gen a) (apply-generic 'atan-gen a))
(define (sin-gen a) (apply-generic 'sin-gen a))

; Now these just need to be defined for each of the number types

(define (install-rational-trig)
	(put 'cos-gen '(rational) 
		(lambda (a) (... code to perform cos on rational number)))
	... etc
	)