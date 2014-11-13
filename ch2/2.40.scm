; Define a procedure unique-pairs that, given an integer n, generates the sequence of pairs (i, j) with 1 <= j < i <= n. Use 
; unique-pairs to simplify the prime-sum-pairs given above.
; =====
; We'll have to set up a couple procedures before we get to unique-pairs. First, we'll define enumerate-interval:
(define (enumerate-interval start end)
	(if (> start end)
		(list)
		(cons start (enumerate-interval (+ start 1) end))))

; We'll also need flatmap so that our pairs are not grouped:
(define (flatmap f seq)
	(accumulate append '() (map f seq)))

; And now we can define unique pairs:
(define (unique-pairs n)
	(flatmap 
		(lambda (i) 
			(map (lambda (j) (list i j)) (enumerate-interval 1 (- i 1))))
		(enumerate-interval 1 n)))

; in action
1 ]=> (unique-pairs 4)
;Value 44: ((2 1) (3 1) (3 2) (4 1) (4 2) (4 3))

; And just to illustrate the difference between flatmap and map, here's what happens when you implement unique-pairs with map
; in place of flatmap:
1 ]=> (unique-pairs 4)
;Value 45: (() ((2 1)) ((3 1) (3 2)) ((4 1) (4 2) (4 3)))

; You get an unwanted layer of nesting. Map preserves the number of entries in the list, so you get n entries for n unique-pairs.
; But with flatmap we append each of these entries to the previous one, removing that extra layer of nesting. I had to play around
; with this a bit to get it. (Didn't help that I made type in defining flatmap that had it behaving just like map)

; Alright, now let's define prime-sum-pairs:
(define (prime-sum-pairs n)
	(define (sum-list l)
		(accumulate + 0 l))
	(map
		(lambda (p) (append p (list (sum-list p))))
		(filter 
			(lambda (p) (prime? (sum-list p)))
			(unique-pairs n))))

