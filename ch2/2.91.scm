; A univariate polynomial can be divided by another one to produce a polynomial quotient and a polynomial remainder. For example,

; (x^5 - 1) / (x^2 - 1) = x^3 + x, remainder x - 1

; Division can be performed via long division. That is, divide the highest-order term of the dividend by the highest-order term of the
; divisor. The result is the first term of the quotient. Next, multiply the result by the divisor, subtract that from the dividend, 
; and produce the rest of the answer by recursively dividing the difference by the divisor. Stop when the order of the divisor exceeds
; the order of the divided and declare the divident to be the remainder. Also, if the dividend ever becomes zero, return zero as both
; quotient and remainder.

; We can design a div-poly procedure on the model of add-poly and mul-poly. The procedure checks to see if two polys have the same
; variable. If so, div-poly strips off the variable and passes the problem to div-terms, which performs the division operation on 
; term lists. div-poly finally reattaches the variable to the result supplied by div-terms. It is convenient to design div-terms
; to compute both the quotient and remainder of a division. div-terms can take two term lists as arguments and return a list of the
; quotient term list and remainder term list.

; Complete the following definition of div-terms by filling in the missing expressions. Use this to implement div-poly, which
; takes two polys as arguments and returns a list of the quotient and remainder polys.
; ========
; 

(define (div-poly p1 p2)
	(if (same-variable? (variable p1) (variable p2))
		(make-poly
			(variable p1)
			(div-terms (term-list p1) (term-list p2)))
		(error "Polys not in same var -- DIV-POLY" (list p1 p2))))

(define (div-terms numer-terms denom-terms)
	(if (empty-termlist? numer-terms)  ; divisor is zero, no remainder
		(list numer-terms numer-terms) ; return two empty lists (with tags)
		(let ((n (first-term numer-terms))
			  (d (first-term denom-terms)))
			(if (> (order d) (order n)) ; base case -> dividend greater than divisor, so divisor becomes remainder, quotient is zero
				(list (the-empty-termlist) numer-terms) ;TODO: update empty-term-list to attach its own tag
				(let ((new-o (sub (order n) (order d)))
					  (new-c (div (coeff n) (coeff d))))
					(let ((rest-of-result 
								(div-terms 
									(sub-terms 
										numer-terms 
										(mul-term-by-all-terms (make-term new-o new-c) denom-terms))  ; new dividend = (current dividend - newest term * divisor)
									denom-terms)))
						(list 
							(adjoin-term (make-term new-o new-c) (car rest-of-result)) ; add first term to quotient
							(cadr rest-of-result)) ; remainder stays the same
						))))))


; And lo! It works:
1 ]=> (define d (make-polynomial 'x '((5 1) (0 -1))))
1 ]=> (define e (make-polynomial 'x '((2 1) (0 -1))))
1 ]=> (div d e)
;Value 274: (polynomial x (dense (3 1) (1 1)) (dense (1 1) (0 -1)))

