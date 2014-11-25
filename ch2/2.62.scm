; Give a O(n) implementation of union-set for sets represented as ordered lists.
; ====
; We'll just implement it as a simple merge. It's O(n) since we operate on each element of each set once at most, looking only at the 
; elements that are at the front of the line. In the case where we get to the end of one set and there are still elements in the 
; other, we just tack them on the end without looking, so it could peform fewer than n operations.
(define (union-set set1 set2)
	(cond ((null? set1) set2)
		((null? set2) set1)
		(else (let ((x1 (car set1)) (x2 (car set2)))
			(cond 
				((< x1 x2) (cons x1 (union-set (cdr set1) set2)))
				((> x1 x2) (cons x2 (union-set set1 (cdr set2))))
				(else (cons x1 (union-set (cdr set1) (cdr set2))))))))) ; x1 = x2


; non-overlapping
1 ]=> (union-set '(1 2 3) '(4 5 6))
;Value 13: (1 2 3 4 5 6)

; elem in set1 that comes after elems in set2
1 ]=> (union-set '(1 2 8) '(4 5 6))
;Value 14: (1 2 4 5 6 8)

; all mixed up
1 ]=> (union-set '(1 2 8) '(0 4 5 6))
;Value 15: (0 1 2 4 5 6 8)

; perfectly overlapping
1 ]=> (union-set '(1 2 8) '(1 2 8))
;Value 16: (1 2 8)
