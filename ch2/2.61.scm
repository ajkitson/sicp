; Give an implementation of adjoin-set using the ordered representation. By analogy with element-of-set? show how to take advantage
; of the ordering to produce a procedure that requires on average about half as many steps as the unordered representation.
; =====
; Recall that when we used an unordered list to represent the set, adjoin-set had to check every element of the set before adding 
; a new element in order to prevent duplicates. If the element existed in the set, we could quit early. But if it didn't, then
; we check every element, making adjoin-set O(n). With an ordered list as the representation, we only need to search for an existing
; element until we hit an element that's greater than the one we're adding. This makes it take about half as many steps to add an 
; element that doesn't exist in the set. However, if the element already exists in the set, it's about the same (which is true of
; element-of-set?, too).
;
; Here's the adjoin-set implementation:
(define (adjoin-set x set)
	(cond 
		((null? set) (list x))	; tack on end of set
		((= x (car set)) set)	; x already exists in set
		((< x (car set)) (cons x set))
		(else (cons (car set) (adjoin-set x (cdr set))))))

1 ]=> (adjoin-set '3 '(1 2 4 5))
;Value 8: (1 2 3 4 5)

1 ]=> (adjoin-set '0 '(1 2 4 5))
;Value 9: (0 1 2 4 5)

1 ]=> (adjoin-set '67 '(1 2 4 5))
;Value 10: (1 2 4 5 67)

1 ]=> (adjoin-set '5 '(1 2 4 5))
;Value 11: (1 2 4 5)