; Suppose you are designing a generic arithmetic system for dealing with the tower of types shown in figure 2.25: integer, rational,
; real, complex. For each type, except complex, design a procedure that raises objects of that type one level in the tower. Show how
; to install a generic raise operation that will work for each type.
; ======
; This is just like all the other operations in the package, with one twise. First we define the global raise procedure, which 
; defers to apply-generic:
(define (raise n)
	(apply-generic 'raise n))

; Then we build a package that installs the raise operation for each type. The only trick is that, instead of performing the 
; coercion itself, each of these procedures defers to get-coercion, so the coercion must be specified in that table

(define (install-raise)
	(define (coerce n type1 type2)
		((get-coercion type1 type2) n))

	(put 'raise '(scheme-number) ; integer->rational
		(lambda (n) (coerce n 'scheme-number 'rational)))

	(put 'raise '(rational)
		(lambda (n) (coerce n 'rational 'real)))

	(put 'raise '(real)
		(lambda (n) (coerce n 'real 'complex)))

	'done)

; of course, we need to have the coercions also installed (and I'm assuming all the selectors/constructors used here
; are already in the table and defined globally so I can access them)
(define (install-raise-coercions)
	(define (make-real n) ; just making this up
		(attach-tag 'real n))

	(put-coercion 'scheme-number 'rational
		(lambda (n) (make-rational n 1))) ; integer is rational number with denominator of 1
	(put-coercion 'rational 'real
		(lambda (n) (make-real (* 1.0 (/ (numer n) (denom n)))))) ; we never talked about how reals are represented, I'm just guessing here
	(put-coercion 'real 'complex
		(lambda (n) (make-from-real-imag n 0)))
	'done)


; Example, from scheme-number to rational
1 ]=> (raise 2)
;Value 126: (rational 2 . 1)

(define get-coercion get)
(define put-coercion put)