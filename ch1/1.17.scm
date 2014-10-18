; The exponentiation algorithms in this section are based on performing exponentiation be means of repeated multiplication.
; In a similar way, one can perform integer multiplication be means of repeated addition. The following multiplication
; procedure is analogous to the expt procedure:

(define (* a b)
	(if (= b 0)
		0
		(+ a (* a (- b 1)))))

; This algorithm takes a number of steps that is linear in b. Now suppose we include, together with addition, operations
; double, which doubles an integer, and halve, which divides an even integer by 2. Using these, design a multiplication
; procedure analogous to fast-expt that uses a logarithmic number of steps.
;====
; My code below. Both versions use these utility procedures:
; 
(define (double x) (+ x x )) 
(define (halve x) (/ x 2)) ; assume we only get even integers
(define (is-even? x) (= (remainder x 2) 0))

; This is a recursive process (for non powers of 2). When we hit an odd b value, we need to wait for the rest of the 
; process to complete before we can fully evaluate. 
(define (* a b) 
	(cond ((or (= b 0) (= a 0)) 0)
		((= b 1) a)
		((is-even? b) (* (double a) (halve b)))
		(else (+ a (* a (- b 1))))))

; Here's an iterative process, where we track any values we have to shave off on odd b-s 
; so we don't have to wait for everything to resolve.
(define (* a b)
	(define (*-iter-internal a b sofar)
		(cond ((= b 1) (+ a sofar))
			((is-even? b) (*-iter-internal (double a) (halve b) sofar))
			(else (*-iter-internal a (- b 1) (+ sofar a)))))
	(cond ((or (= a 0) (= b 0)) 0) ; check here so we don't have to worry about it internally
		(else (*-iter-internal a b 0))))

; Are these logarithmic? Well, first observe that the operations vary with values for b (not a).
; For any given value b that takes n runs of the procedure, 2b will take n + 1 runs at most. 
; So yep, it's runs in logarithmic time

; NOTE: None of these handles mulitplying two negative integers. If b < 0, then we recurse infinitely. 
; Here's a wrapper that could fix this, applied to the first algorithm, but the same principle holds:
(define (* a b)
	(define (*-internal a b)
		(if (= b 0)
			0
			(+ a (*-internal a (- b 1)))))
	(if (< b 0)
		(- 0 (*-internal a (- 0 b))) ; flip b, compute a * b, then flip back (-b = 0 - b, and b = 0 - -b)
		(*-internal a b)))

