; Define a generic equality predicate equ? that tests the equality of two numbers, and install it in the generic arithmetic package.
; This operation should work for ordinary nukner, rational numbers, and complex numbers.
; ======
; We'll do this in a few steps. First we define equ? in the global scope. This procedure defers to apply-generic. Then we install
; procedures in the central table that will check equality on th types of numbers we want to support.
;
; Writing the equ? procedure and package turned out to be simple (though getting all the supporting code in place was a pain)

(define (equ? x y) (apply-generic 'equ? x y))

(define (install-equ?)
	; internal procedures
	(define (numer x) (car x))
	(define (denom x) (cdr x))
	(define (real-part x) 
		(apply-generic 'real-part x))
	(define (imag-part x) 
		(apply-generic 'imag-part x))

	; interface
	(put 'equ? '(scheme-number scheme-number)
		(lambda (x y) (= x y)))
	(put 'equ? '(rational rational)
		(lambda (x y) 
			(and (= (numer x) (numer y)) 
				(= (denom x) (denom y)))))
	(put 'equ? '(complex complex)
		(lambda (x y) ; just use real and imaginary parts and don't try anything fancy with figuring out what format it's in
			(and (= (real-part x) (real-part y))  ; this assumes polar numbers will be converted precisely enough to satisfy = if comparing w/rectangular
				(= (imag-part x) (imag-part y))))))


; Scheme numbers:
1 ]=> (equ? 4 5)
;Value: #f
1 ]=> (equ? 4 4)
;Value: #t

; Rational numbers:
1 ]=> (equ? (make-rational 5 10) (make-rational 2 4))
;Value: #t
1 ]=> (equ? (make-rational 5 10) (make-rational 2 3))
;Value: #f

; Complex numbers (just doing rectangular since I don't have the full complex package set up):
1 ]=> (equ? (make-from-real-imag 4 5) (make-from-real-imag 5 6))
;Value: #f
1 ]=> (equ? (make-from-real-imag 4 5) (make-from-real-imag 4 5))
;Value: #t






; Some hacked together packages for complex and rational numbers:
(define (install-complex-package)
	(define (make-from-real-imag x y)
		((get 'make-from-real-imag 'rectangular) x y))
	(define (make-from-mag-ang r a)
		((get 'make-from-mag-ang 'polar) r a))
	(define (real-part z)
		((get 'real-part 'rectangular) z))
	(define (imag-part z)
		((get 'imag-part 'rectangular) z))

	(define (tag z) (attach-tag 'complex z))
	(put 'real-part 'complex real-part)
	(put 'imag-part 'complex imag-part)
	(put 'make-from-real-imag 'complex
		(lambda (x y) (tag (make-from-real-imag x y))))
	(put 'make-from-mag-ang 'complex
		(lambda (r a) (tag (make-from-mag-ang r a))))
	'done)

(define (make-from-mag-ang r a)
	((get 'make-from-mag-ang 'complex) r a))
(define (make-from-real-imag x y)
	((get 'make-from-real-imag 'complex) x y))

(define (install-rect-and-polar) ;hack, just so I can create some complex numbers
	(define (real-part z) (car z))
	(define (imag-part z) (cdr z))

	(define (make-from-real-imag x y) (cons x y))
	(define (make-from-mag-ang r a) (cons r a))
	(put 'real-part '(rectangular) real-part)
	(put 'imag-part '(rectangular) imag-part)
	(put 'make-from-real-imag 'rectangular
		(lambda (x y) (attach-tag 'rectangular (make-from-real-imag x y))))
	(put 'make-from-mag-ang 'polar
		(lambda (r a) (attach-tag 'polar (make-from-mag-ang r a))))
	'done)


(define (install-rational-package)
	(define (make-rat n d)
		(let ((g (gcd n d)))
			(cons (/ n g) (/ d g))))
	(define (tag x) (attach-tag 'rational x))
	(put 'make 'rational 
		(lambda (n d) (tag (make-rat n d))))
	'done)
(define (make-rational n d)
	((get 'make 'rational) n d))