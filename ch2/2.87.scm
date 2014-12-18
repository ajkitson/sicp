; Install =zero? for polynomials in the generic arithmetic package. This will allow adjoin-term to work for polynomials with 
; coefficients that are themselves polynomials.
; ====
; How do we know if a polynomial is zero? I suppose if we have the empty term list or all the polynomial's coefficients are zero.
; We already have the empty-termlist? predicate. That takes care of the termlist. Do we also have to check that all coefficients
; are not zero? No we don't. adjoin-term already checks to make sure that the coefficient on new terms are not zero before adding
; them to the polynomial. As long as we use adjoin-term to construct polynomials (and we should--add-poly and mul-poly do), we
; can't have zero coefficients in our polynomial. 
; 
; Below is the =zero? code from 2.80, with polynomial support added:

(define (=zero? x) (apply-generic '=zero? x))
(define (install-zero-package)
	(define (zero? x) (= x 0))

	(put '=zero? '(scheme-number) zero?)
	(put '=zero? '(rational)
		(lambda (x) (zero? (numer x))))
	(put '=zero? '(complex)
		(lambda (x) 
			(and (zero? (real-part x))
				(zero? (imag-part x)))))
	(put '=zero? '(polynomial) empty-termlist) ;ADDED to support polynomials (empty-termlist? already made globally available)
	'done)


; Earlier, I set up a as a poly: a = x^2 + 5
]=> a
;Value 164: (polynomial x (2 1) (0 5))

; Now we define a polynomial on y with a as a coefficient: c = (x^2 + 5)y^2
1 ]=> (define c (make-poly 'y (list (list 2 a))))
1 ]=> c
;Value 179: (polynomial y (2 (polynomial x (2 1) (0 5))))

; Here's c + c
1 ]=> (add c c)
;Value 180: (polynomial y (2 (polynomial x (2 2) (0 10))))

; and c * c
1 ]=> (mul c c)
;Value 181: (polynomial y (4 (polynomial x (4 1) (2 10) (0 25))))


; Note that this only works if all coefficients are polynomials. This is because we never defined a coercion to polynomials
; from the other number types, so it doesn't know how to, say, add a coefficient of 1 to (x + 2).
;
; However, we can mix the other number types. Here we have b, with a rational coefficient:
1 ]=> b
;Value 172: (polynomial x (4 2) (2 (rational 5 1)))
1 ]=> (add a b)
;Value 182: (polynomial x (4 2) (2 6) (0 5))
1 ]=> (mul a b)
;Value 183: (polynomial x (6 2) (4 15) (2 25))
