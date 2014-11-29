; Show how to extend the basic differentiator to handle more kinds of expressions. For instance, implement the differentiation rule

; d(u^n)/dx = n(u^n-1)(du/dx)

; by adding a new clause to the deriv program and defining appropriate procedures exponentiation?, base, exponent, and 
; make-exponentiation. (You may use the symbol ** to denote exponentiation.) Build in the rules that anything raised to the power 0 
; is 1 and anything raised to the power 1 is the thing itself.
; =====
; Let's start from the top by adding this to deriv:


(define (deriv exp var)
	(cond 
		((number? exp) 0)
		((variable? exp)
			(if (same-variable? exp var) 1 0))
		((sum? exp)
			(make-sum 
				(deriv (addend exp) var)
				(deriv (augend exp) var)))
		((product? exp)
			(make-sum
				(make-product 
					(multiplier exp) (deriv (multiplicand exp) var))
				(make-product
					(multiplicand exp) (deriv (multiplier exp) var))))
		((exponentiation? exp)
			(make-product
				(make-product 
					(exponent exp) 
					(make-exponentiation (base exp) (- (exponent exp) 1)))
				(deriv (base exp) var)))
		(else (error "we don't know what you mean!"))))

; and now the supporting procedures:
(define (exponentiation? x)
	(and (pair? x) (eq? (car x) '**)))
(define (base x) (cadr x))
(define (exponent x) (caddr x))
(define (make-exponentiation base exponent)
	(cond 
		((=number? exponent 0) 1)
		((=number? exponent 1) base)
		((and (number? base) (number? exponent)) (expt base exponent))
		(else (list '** base exponent))))

; and here it is:
1 ]=>(deriv '(** x 2) 'x)
;Value 2: (* 2 x)
1 ]=> (deriv '(* 5 (** x 3)) 'x)
;Value 8: (* 5 (* 3 (** x 2)))
