; Louis Reasoner has noticed that apply-generic may try to coerce the arguments to each other's type even if they already have the 
; same type. Therefore, he reasons, we need to put procedures in the coercion table to "coerce" arguments of each type to their own 
; type.For example, in addition to the scheme-number->complex coercion shown above, he would do:

; (define (scheme-number->scheme-number n) n)
; (define (complex->complex z) z)
; (put-coercion 'scheme-number 'scheme-number
; 	scheme-number->scheme-number)
; (put-coercion 'complex 'complex complex->complex)

; a. With Louis' coercion procedures installed, what happens if apply-generic is called with two arguments of type scheme-number
; 	or two arguments of type complex for an operation that is not found in the table for those types? For example, assume that
; 	we've defined a generic exponentiation operation:

; 	(define (exp x y) (apply-generic 'exp x y))

; 	and have put a procedure for exponentiation in the scheme-number package by not in any other package:

; 	;;following added to scheme-number package
; 	(put 'exp '(scheme-number scheme-number)
; 		(lambda (x y) (tag (expt x y)))) ; using primitive expt

; 	What happens if we call exp with two complex numbers as arguments?

; b. Is Louis correct that something had to be done about coercion with arguments of the same type, or does apply-generic work 
; 	correctly as is?

; c. Modify apply-generic so that it doesn't try coercion if the two arguments have the same type.
; =======
; a. This is a weird one. I'm not sure why we're entertaining Louis with this. We only try to coerce arguments of the same type if
; 	we failed to find a procedure for that operator and argument type combo already. This doesn't change if few coerce the 
; 	arguments to their existing type. In fact, it introduces an infinite loop. When we find the coercion, we'll call apply-generic
; 	again with the coerced types. But under Louis' scheme, the types don't actually change, so we again fail to find a procedure, 
; 	just as we did the first time, but we do find a coercion, so we call apply-generic again with the coerced types, which are 
; 	actually the same types and the process starts all over again. For apply-generic to work, the coercion must actually change
; 	the types.
;
; b. Louis is incorrect. Nothing *needs* to be done about coercion with arguments of the same type. apply-generic works correctly,
; 	if a little inefficiently. If the arguments are of the same type, there's no need to go through the process of looking up
;	coersion procedures. But if arguments are the same type (and we're NOT followig Louis' scheme), then we fail to find a coercion
; 	procedure (get-coercion fails) and we error out with a "no method found error", which is entirely appropriate. 
;
; c. But, if the arguments are of the same type there's no point in doing the coercion lookup, so we can be a little more efficient
; 	there:

(define (apply-generic op . args)
	(define (lookup-error op tags)
		(error "No method for these types" (list op tags)))
	(let ((type-tags (map type-tag args)))
		(let ((proc (get op type-tags)))
			(if proc
				(apply proc (map contents args))
				(if (and (= (length args) 2) 
						(not (eq? (car type-tags) (cadr type-tags))))  ; ADDED to prevent attempted coercion on same type
					(let ((type1 (car type-tags))
							(type2 (cadr type-tags))
							(a1 (car args))
							(a2 (cadr args)))
						(let ((t1->t2 (get-coercion type1 type2))
							(t2->t1 (get-coercion type2 type1)))
							(cond
								(t1->t2 (apply-generic (t1->t2 a1) a2))
								(t2->t1 (apply-generic a1 (t2->t1 a2)))
								(else (lookup-error op type-tags)))))
					(lookup-error op type-tags))))))




