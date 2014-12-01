; Section 2.3.2 described a program that performs symbolic differentiation:


; (define (deriv exp var)
; 	(cond 
; 		((number? exp) 0)
; 		((variable? exp)
; 			(if (same-variable? exp var) 1 0))
; 		((sum? exp)
; 			(make-sum 
; 				(deriv (addend exp) var)
; 				(deriv (augend exp) var)))
; 		((product? exp)
; 			(make-sum
; 				(make-product 
; 					(multiplier exp) (deriv (multiplicand exp) var))
; 				(make-product
; 					(multiplicand exp) (deriv (multiplier exp) var))))
; 		(else (error "we don't know what you mean!"))))

; We can regard this program as performing a dispatch on the type of the expression to be differentiated. In this situation, the "type
; tag" of the datum is the algebrain operator symbol (such as +) and the operation being perfromed is deriv. We can transform this
; program into a data-directed style by rewriting the basic derivative procedure as

(define (deriv exp var)
	(cond 
		((number? exp) 0)
		((variable? exp) (if (same-variable? exp var) 1 0))
		(else ((get 'deriv (operator exp)) (operands exp) var))))

(define (operator exp) (car exp))
(define (operands exp) (cdr exp))

; a. Explain what was done above. Why can't we assimilate the predicates number? and same-variable? into the data-directed dispatch?

; b. Write the procedures for derivatives of sums and products, and the auxiliary code required to install them in the table used by
; 	the program above

; c. Choose any additional differentiation rule that you like, such as the one for exponents (exercise 2.56) and install it in this
; 	data-directed system

; d. In this simple algebraic manipulator the type of an expression is the algebraic operator that binds it together. Suppose, however,
; 	we indexed the procedures in the opposite way, so that the dispatch line in deriv looked like

; 	((get (operator exp) 'deriv) (operands exp) var)

; 	What corresponding changes to the derivative system are required?

; ================
; a. Derivatives are done differently depending on the operator of the expression. Previously, we defined how to take the derivative
; 	of each operator in the deriv procedure itself. Now deriv doesn't need to know anything about how derivatives are performed
; 	for different operators. It just gets the operator of the expression and then uses get to look up the appropriate procedure.
; 	We can add support for new operators just by updating the table--we don't need to touch deriv at all.
;
; 	The predicates number? and variable? don't fit nicely into this scheme since, in this case, there is no operator to look up
; 	in the table. Now, if we wanted to centralize the derivation procedures in the table, we could add them. Instead of checking
; 	for number? and returning 0, we could look up procedure tagged number in the table that would return 0. Ditto for same-variable?
;   But just adds complexity without any corresponding simplification since we still need special checks for number? and same-variable?
; 	in deriv.
;
; 	b. We can just grab the code for sums and products from the original deriv procedure, and package them as procedures with their
;	supporting code and then put them in the table. We need to update addend and augend to work when just passed the operands
;	and not the entire expression. (I could also have added the operator back by passing (cons '+ operands) to addend, etc.). I 
; 	used the below implementation of get and put to test (pulled from SO: http://stackoverflow.com/questions/5499005/how-do-i-get-the-functions-put-and-get-in-sicp-scheme-exercise-2-78-and-on)

(define (install-deriv-package)
	; internal procedures
	(define (=number? x n)
		(and (number? x) (= x n)))
	(define (addend operands) (car operands))
	(define (augend operands) (cadr operands)) ;assuming just two operands per expression
	(define (make-sum a b)
	  (cond ((=number? a 0) b)
	        ((=number? b 0) a)
	        ((and (number? a) (number? b)) (+ a b))
	        (else (list '+ a b))))
	(define (multiplier operands) (car operands))
	(define (multiplicand operands) (cadr operands))
	(define (make-product a b)
		(cond ((or (=number? a 0) (=number? b 0)) 0)
			((=number? a 1) b)
			((=number? b 1) a)
			((and (number? a) (number? b)) (* a b))
			(else (list '* a b))))

	; interface to rest of system
	(put 'deriv '+ 
		(lambda (operands var) 
			(make-sum 
				(deriv (addend operands) var)
				(deriv (augend operands) var))))
	(put 'deriv '*
		(lambda (operands var)
			(make-sum
				(make-product
					(multiplier operands)
					(deriv (multiplicand operands) var))
				(make-product 
					(multiplicand operands)
					(deriv (multiplier operands) var))))))


1 ]=> (install-deriv-package)
1 ]=> (deriv '(* x y) 'x)
;Value: y
1 ]=> (deriv '(+ x 3) 'x)
;Value: 1
1 ]=> (deriv '(* (* x y) (+ x 3)) 'x)
;Value 22: (+ (* x y) (* (+ x 3) y))


; c. Now we'll just add exponents:

(define (install-deriv-package)
	; internal procedures
	(define (=number? x n)
		(and (number? x) (= x n)))
	(define (addend operands) (car operands))
	(define (augend operands) (cadr operands)) ;assuming just two operands per expression
	(define (make-sum a b)
	  (cond ((=number? a 0) b)
	        ((=number? b 0) a)
	        ((and (number? a) (number? b)) (+ a b))
	        (else (list '+ a b))))
	(define (multiplier operands) (car operands))
	(define (multiplicand operands) (cadr operands))
	(define (make-product a b)
		(cond ((or (=number? a 0) (=number? b 0)) 0)
			((=number? a 1) b)
			((=number? b 1) a)
			((and (number? a) (number? b)) (* a b))
			(else (list '* a b))))
	;adding exponentiation
	(define (base x) (car x))
	(define (exponent x) (cadr x))
	(define (make-exponentiation base exponent)
		(cond 
			((=number? exponent 0) 1)
			((=number? exponent 1) base)
			((and (number? base) (number? exponent)) (expt base exponent))
			(else (list '** base exponent))))

	; interface to rest of system
	(put 'deriv '+ 
		(lambda (operands var) 
			(make-sum 
				(deriv (addend operands) var)
				(deriv (augend operands) var))))
	(put 'deriv '*
		(lambda (operands var)
			(make-sum
				(make-product
					(multiplier operands)
					(deriv (multiplicand operands) var))
				(make-product 
					(multiplicand operands)
					(deriv (multiplier operands) var)))))
	(put 'deriv '**
		(lambda (operands var)
			(make-product
				(make-product 
					(exponent operands) 
					(make-exponentiation (base operands) (- (exponent operands) 1)))
				(deriv (base operands) var)))))

1 ]=> (deriv '(** x 2) 'x)
;Value 48: (* 2 x)

1 ]=> (deriv '(* 5 (** x 3)) 'x)
;Value 49: (* 5 (* 3 (** x 2)))


; d. All we would need to do is swap the order of 'deriv and the operator symbol when calling put, e.g.:
	(put '+ deriv 
		(lambda (operands var) 
			(make-sum 
				(deriv (addend operands) var)
				(deriv (augend operands) var))))

; This works fine. However, now the differentiation operations are not grouped in a deriv package, but are spread out as 
; operations across a '+ package, and a '* package, etc. This could make portability more difficult. It could also lead to 
; conflicts if a separate '+ package is installed


; Here are the supporting procedures:
(define (variable? x) (symbol? x))
(define (same-variable? x y) (eq? x y))

(define global-array '())

(define (make-entry k v) (list k v))
(define (key entry) (car entry))
(define (value entry) (cadr entry))

(define (put op type item)
  (define (put-helper k array)
    (cond ((null? array) (list(make-entry k item)))
          ((equal? (key (car array)) k) array)
          (else (cons (car array) (put-helper k (cdr array))))))
  (set! global-array (put-helper (list op type) global-array)))

(define (get op type)
  (define (get-helper k array)
    (cond ((null? array) #f)
          ((equal? (key (car array)) k) (value (car array)))
          (else (get-helper k (cdr array)))))
  (get-helper (list op type) global-array))


