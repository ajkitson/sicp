; The sum procedure is only the simplest of a vast number of similar abstractions that can be captured as higher order procedures. Write 
; an analogous procedure called product that returns the product of the values of a function at points over a given range. Show how to 
; define factorial in terms of product. Also use product to compute approximations of pi using the formula:

; pi/4 = 2/3 * 4/3 * 4/5 * 6/5 * 6/7 * 8/7 ...

; If your product procedure generates a recursive process, write one that generates in iterateive process and vice versa.
; ======
; product is very similar to sum. We just return 1 when we hit the base case and multiply instead of add:
(define (product f a next b)
	(if (> a b)
		1
		(* (f a)
			(product f (next a) next b))))

; we can write factorial thusly:
(define (factorial n)
	(define (self a) a) ; is this necessary?
	(define (inc x) (+ x 1))
	(product self 1 inc n))

; and now let's look at the approximation of pi:
(define (pi n)
	(define (inc x) (+ x 1))
	(define (get-fraction k)
		(if (even? k)
			(/ (+ k 2) (+ k 1))
			(/ (+ k 1) (+ k 2))))
	(* 4.0 (product get-fraction 1 inc n)))


; now let's convert product to an iterative process:
(define (product f a next b)
	(define (iter a result)
		(if (> a b)
			result
			(iter (next a) (* (f a) result))))
	(iter a 1))

