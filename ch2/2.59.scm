; Implement the union-set operation for the unordered list representation of sets
; =====
; We've already implemented the procedures element-of-set?, adjoin-set, and intersection-set for unordered sets. For union-set, we
; can just take two sets and use adjoin-set to move the elements of one into the other. adjoin-set checks whether an element
; already exists in the target set, so no point in duplicating that logic in union-set.

(define (union-set set1 set2)
	(if (null? set1)
		set2
		(union-set (cdr set1) (adjoin-set (car set1) set2))))


; In action:
1 ]=> (union-set '(1 2 3) '(2 3 4 5))
;Value 3: (1 2 3 4 5)

; supporting code from the book:
(define (element-of-set? x set)
	(cond ((null? set) false)
		((equal? x (car set)) true)
		(else (element-of-set? x (cdr set)))))

(define (adjoin-set x set)
	(if (element-of-set? x set)
		set
		(cons x set)))