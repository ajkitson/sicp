; Using the results of exercises 1.16 and 1.17, devise a procedure that generates an iterative process for multiplying
; two integers in terms of adding, doubling, and halving and uses logarithmic steps.
;
; ======
; Oops! I already did this as part of 1.17. here's the code, cleaned up a bit:

(define (* a b)

	(define (double x) (+ x x )) 
	(define (halve x) (/ x 2)) ; assume we only get even integers
	(define (is-even? x) (= (remainder x 2) 0))

	(define (*-iter-internal a b sofar)
		(cond ((= b 0) sofar)
			((is-even? b) (*-iter-internal (double a) (halve b) sofar))
			(else (*-iter-internal a (- b 1) (+ sofar a)))))

	(if (= a 0) 
		0 ; check here so we don't have to worry about it internally
		(*-iter-internal a b 0)))
