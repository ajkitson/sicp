; Use the results of exercises 2.63 and 2.64 to give O(n) implementations of union-set and intersection-set for set implemented as
; balanced binary trees.
; =====
; Let's start by talking about two of the major constraints: that the trees be balanced and that we operate in O(n) time. Both
; of these constraints point towards converting from trees to list and then back to trees. If the lists are to be balanced, we 
; cannot simply use adjoin-set to add elements. At some point we need to convert to a list and back to a tree. And if we're going
; to obtain O(n) time, we cannot use element-of-set?, which is logn for each element we call it on, or O(nlogn) overall, more than
; we want.
;
; However, back in 2.62, we implemented union-set in O(n) time when working with two ordered lists, pulling the smallest element
; from the front of each list. (The operation is similar for intersection-set.) So we can convert each tree to a list (which 
; works in O(n) time, then perform the merge in O(n) time, and convert back to trees in O(n) time. That adds up to O(3n), but the
; constant factor doesn't count, so we just get O(n).

(define (union-set set1 set2)
	(define (union-set-list set1 set2)
		(cond 
			((null? set1) set2)
			((null? set2) set1)
			(else (let ((x1 (car set1)) (x2 (car set2)))
				(cond 
					((< x1 x2) (cons x1 (union-set-list (cdr set1) set2)))
					((> x1 x2) (cons x2 (union-set-list set1 (cdr set2))))
					(else (cons x1 (union-set-list (cdr set1) (cdr set2))))))))) ; x1 = x2
	(list->tree 
		(union-set-list (tree->list set1) (tree->list set2))))


(define (intersection-set set1 set2)
	(define (intersection-set-list set1 set2)
		(if (or (null? set1) (null? set2)) ;if either is null, remaining elems of other set cannot be in intersection
			'()
			(let ((x1 (car set1)) (x2 (car set2)))
				(cond
					((equal? x1 x2)  ; in both! add to intersection
						(cons x1 (intersection-set-list (cdr set1) (cdr set2))))
					((< x1 x2) (intersection-set-list (cdr set1) set2))		 ; if x1 < x2, x1 cannot be in intersection
					((> x1 x2) (intersection-set-list set1 (cdr set2)))))))	 ; vice versa
	(list->tree
		(intersection-set-list (tree->list set1) (tree->list set2))))

; In action:
1 ]=> (define s1 (list->tree '(1 3 5 7 9 11)))
1 ]=> (define s2 (list->tree '(1 2 3 4 5 6)))
1 ]=> (tree->list (intersection-set s1 s2))
;Value 17: (1 3 5)
1 ]=> (tree->list (union-set s1 s2))
;Value 18: (1 2 3 4 5 6 7 9 11)



