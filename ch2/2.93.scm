; Modify the rational-arithmetic package to use generic operations,
; but change make-rat so that it does not attempt to reduce fractions
; to lowest terms. Test your system be calling make-ratioanl on two
; polynomials to produce a rational function

(define p1 (make-polynomial 'x '((2 1) (0 1))))
(define p2 (make-polynomial 'x '((3 1) (0 1))))
(define rf (make-rational p1 p2))

; Now add rf to itself using add. You will observe that this addition
; procedure does not reduce fractions to lowest terms.
; =====
; I already had the rational number arithmetic package using the generic operations
; so we just need to modify make-rational. We'll simply update the constructor 
; internal to the arithmetic package:

(define (make-rat n d) (list n d))


1 ]=> (add rf rf)
;Value 118: (rational (polynomial x dense (5 2) (3 2) (2 2) (0 2))
;(polynomial x dense (6 1) (3 2) (0 1)))

; This isn't as simplified as it could be, but it's correct. 
;
; This also shook out a few bugs. I wasn't returning the correct value frm div-poly. I 
; was passing the quotient and remainder to drop and that was causing errors.
;
;
; To make this simpler, we'll update add-rat to first check if the denominators are
; already the same and, if so, just add the numerators:

  (define (add-rat x y)
    (if (equ? (denom x) (denom y))
	(make-rat
	 (add (numer x) (numer y))
	 (denom x))
	(make-rat
	 (add
	  (mul (numer x) (denom y))
	  (mul (denom x) (numer y)))
	 (mul (denom x) (denom y)))))

; And this works!

;Value 40: (rational (polynomial x dense (2 2) (0 2)) (polynomial x
;dense (3 1) (0 1)))



