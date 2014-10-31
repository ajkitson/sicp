; You can obtain an even more general version of accumulate by introducing the notion of a filter on the terms to be combined. That is,
; combine only those terms derived from values in the range that satisfy a specified condition. The resulting filtered-accumulate
; abstraction takes the same arguments as accumulate, together with an additional predicate of one argument that specifies the filter.
; Write filtered-accumulate as a procedure. Show how to express the following using filtered-accumulate:

; a. the sum of the squares of the prime number in the interval a to be
; b. the product of all the positive integers less than n that are relatively prime to n (i.e. all positive integers i < n such that
; 	GCD(i, n) = 1.
;=====
; We just add the filter argument and then choose whether to pass the (term a) or null-value to the combiner
(define (filtered-accumulate filter combiner null-value term a next b)
	(if (> a b)
		null-value
		(combiner (if (filter a) (term a) null-value)
				(filtered-accumulate filter combiner null-value term (next a) next b))))

; Here's sum-prime-square. I pulled prime? from one of the earlier exercises, just going with the most compact definition for now
(define (sum-prime-squares a b)
	(define (inc n) (+ n 1))
	(define (prime? n)
		(define (smallest-divisor n)
			(define (smallest-divisor-iter n test) 
				(cond ((< n (square test)) n) ; n is its own smallest divisor if none found less than sqrt(n)
					((= (remainder n test) 0) test)
					(else (smallest-divisor-iter n (+ test 1)))))
			(smallest-divisor-iter n 2))
		(= (smallest-divisor n) n))	
	(filtered-accumulate prime? + 0 square a inc b))

; Here's the product of all pos ints < n that are prime relative to n:
(define (primes-to-n-product n)
	(define (inc n) (+ n 1))
	(define (self n) n)
	(define (prime-to-n a) (= (gcd a n) 1))
	(filtered-accumulate prime-to-n * 1 self 1 inc n))

