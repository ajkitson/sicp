; Write a procedure to find all ordered triples of distinct positive integers i, j, and k less than or equal to a given integer n that
; sum to a given integer s.
; ====
; We just wrote a unique-pairs procedure for 2.40. Unique triples are going to be unique pairs, combined with numbers less than 
; their lowest number (the second number in our ordered pair). We can use flatmap to go over all unique pairs and combine each 
; pair with the numbers that are lower than it's second number.
; The check on their sum is straightforward with filter--just pass our triple list through a filter that compares sum-list to 
; the s argument.
; Here we go:

(define (triples-sums-to s n)
	(define (sum-list l) ; add up a list
		(accumulate + 0 l))
	(filter 
		(lambda (triple) (= (sum-list triple) s)) ; triple sums to s
		(distinct-ordered-triple n)))

; generate triples i, j, k, where 1 <= k < j < i <= n
(define (distinct-ordered-triple n)
	(flatmap
		(lambda (p)
			(map 
				(lambda (k) (append p (list k)))
				(enumerate-interval 1 (- (cadr p) 1))))
		(unique-pairs n)))


