; Using the raise operation of exercise 2.83, modify the apply-generic procedure so that it coerces its arguments to have the same type
; by the method of successive raising, as discussed in this section. You will need to devise a way to test which of two types is 
; higher or lower in the tower. Do this in a manner that is "compatible" with the rest of the system and will not lead to problems
; in adding new levels to the tower.
; ======
; Let's start with how we can tell which types are greater than the others. Initially, I had been tempted to try to read this out 
; of the coercion table. For example, if theres a conversion from type A to type B, then B is higher than A. But this doesn't feel
; quite right since there could be coercions the other way, too (though maybe with some loss of precision, e.g. real to integer). So
; we shouldn't use the conversion table to figure this out.
;
; We could see if there is a raise procedure that leads from one type to another. That would allow us to infer greater and less 
; than relationships without having to explicitly define it elsewhere (which would be another thing to maintain). But that seems
; like too much work at runtime since, at least the way we wrote raise, we would have to actually perform the series of raises
; in order to get the list
;
; Just checking against a list would be ideal, but I don't like having to maintain yet another things with this package. Let's 
; do this. We'll have a greater-than or raises-to operation that starts with an integer and successively raises it, building
; a list of the type-tags that are used along the way. This isn't super efficient, but these are simple operations so it's probably
; OK (and 2.85 has us doing something similar anyway).

; Here's our raises-to operation. It just checks whether typeA can be raised to typeB. It constructs the tower of types dynamically
; by raising an integer all the way to a complex number and 
(define (raises-to typeA typeB)
	(define (a-before-b a b seq)
		(define (remaining-elems a seq) ; return elems after a in seq
			(cond 
				((null? seq) '())
				((equal? (car seq) a) (cdr seq))
				(else (remaining-elems a (cdr seq)))))
		(not (not (some   ; coerce to bool :)
			(lambda (e) (equal? e b))
			(remaining-elems a seq)))))
	(define (types-starting-with n)
		(let ((next-n (raise n)))
			(if (not (next-n))
				'()
				(cons (type-tag n) (types-starting-with next-n)))))
	(a-before-b typeA typeB (types-starting-with 1)))

; We want to know the highest type of operand so we can convert the others to it
(define (highest-type num-types)
	(accumulate
		(lambda (n max) (if (raises-to n max) max n))
		'scheme-number
		num-types))

; Now let's write a procedre that will successively raise a number to a specified type (assumes you've already checjed to make sure n isn't lower than type we're trying to raise to)
(define (raise-until n type)
	(if (eq? (type-tag n) type)
		n 	; got the type we're looking for
		(raise-until (raise n) type)))

; And finally, we update apply-generic. Now it will simply map raise-until over the arguments until it's of the highest type
(define (apply-generic op . args)
	(define (lookup-error op tags)
		(error "No method for these types" (list op tags)))
	(let ((type-tags (map type-tag args)))
		(let ((proc (get op type-tags)))
			(if proc
				(apply proc (map contents args))
				(if (= (count-uniques type-tags) 1) ; if already same type, don't coerce
					(lookup-error op type-tags)
					(let ((coerce-to (highest-type type-tags)))
						(apply 
							apply-generic 
							(cons op (map (lambda (a) (raise-until a coerce-to)) args)))))))))
