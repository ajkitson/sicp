; Define a procedure last-pair that returns the list that contains only the last element of a given (non-empty) list.
; ======
; I see two easy ways to do this. The first makes use of the built-in list-ref and length procedures:
(define (last-pair l)
	(list (list-ref l (- (length l) 1))))

; This is nice and concise and builds on list-ref and length. However, it's (pretty sure) a bit inefficient since we traverse the list
; twice, once to compute length and the second time with list-ref. That's what the length and list-ref implementations given in the 
; book do, anyway.
; This should be faster:
(define (last-pair2 l)
	(if (null? (cdr l))
		l
		(last-pair2 (cdr l))))

; Both of these work as described (each returns a list and not just the last value):
1 ]=> (last-pair2 (list 12 85 29 79))
;Value 4: (79)
1 ]=> (last-pair (list 12 85 29 79))
;Value 5: (79)



; Let's see if it really is faster:
(define (timed-loop val fn n)
	(define start-time (runtime))
	(define (loop-n n)
		(fn val)
		(if (= n 0)
			(display (- (runtime) start-time))
			(loop-n (- n 1))))
	(loop-n n))

; Actually, the first implementation is faster. The built-in length and list-ref must be optimized in some way, because the 
; implementations in the book do the same traversal that last-pair2 does, but twice. Maybe there's some sort of caching? If so, these
; gains might be lost if we don't reuse the same list for each iteration of the test. I'll leave that as speculation for now.

1 ]=> (timed-loop (list 1 2 3 4 5 6 7 8 9) last-pair 10000000)
12.679999999999993

1 ]=> (timed-loop (list 1 2 3 4 5 6 7 8 9) last-pair2 10000000)
47.349999999999994