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
; in order to get the list...
;
; So, instead of trying to be clever about it, we'll just have a list that defines the hierarchy and check against that. When we 
; add types, we'll have to update the list, but that's trivial and allows us to change other pieces of how we handle coercion without
; worrying about breaking raises-to. If it turns out to be an issue, we can alway generate the tower list dynamically (e.g. start
; with an int and raise it until we don't have a type to raise it to... would need to add a way to detect that we don't have anywhere
; to raise it--currently we just get an error that a coercion proc couldn't be found).
;
; Here's our raises-to procedure:

(define (raises-to typeA typeB)
	(define tower (list 'scheme-number 'rational 'complex))
	(define (position x seq) ; zero-indexed
		(define (pos-iter seq ix)
			(cond
				((null? seq) -1)
				((equal? x (car seq)) ix)
				(else (pos-iter (cdr seq) (+ ix 1)))))
		(pos-iter seq 0))
	(define (before a b seq)	; return false if elements not in list at all
		(let ((pos-a (position a seq))
			 (pos-b (position b seq)))
			(and 
				(not (= pos-a -1)) ; a is in the list
				(< pos-a pos-b)))) ; and a comes before b
	(before typeA typeB tower))


; We want to know the highest type of operand so we can convert the others to it
(define (highest-type num-types)
	(accumulate
		(lambda (n max) (if (raises-to n max) max n))
		(car num-types)
		(cdr num-types)))

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
				(let ((coerce-to-type (highest-type type-tags)))
					(if (every  ;; every type is already the highest type --> nothing to coerce to!
							(lambda (type) (equal? type coerce-to-type)) 
							type-tags)
						(lookup-error op type-tags)
						(apply ; have to use apply here or args could get nested in one too many lists
							apply-generic
							(cons 
								op 
								(map (lambda (a) (raise-until a coerce-to-type)) args)))))))))


; And it works!

; Still works for same type:
1 ]=> (add 4 5)
;Value: 9

; And still works for one step, where we have a direct raise proc
1 ]=> (add 4 (make-rational 5 6))
;Value 211: (rational 29 6)

; But now we can leap all the way up to complex numbers:
1 ]=> (add 4 (make-complex-from-real-imag 5 6))
;Value 212: (complex rectangular (rational 9 1) . 6)

; Args in the other order work, too:
1 ]=> (add (make-complex-from-real-imag 5 6) 4)
;Value 213: (complex rectangular (rational 9 1) . 6)

; And we still recognize when we don't have a proc:
1 ]=> (test 4 5)

;Unbound variable: test
;To continue, call RESTART with an option number:
; (RESTART 3) => Specify a value to use instead of test.
; (RESTART 2) => Define test to a given value.
; (RESTART 1) => Return to read-eval-print level 1.

2 error> 
;Quit!

1 ]=> (apply-generic 'test 1 3)

;No method for these types (test (scheme-number scheme-number))
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.


