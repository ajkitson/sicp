; We specified that a set would be represented as a list with no duplicates. Now suppose we allow duplicates. For instance, the set
; { 1, 2, 3 } could be represented as the list (2 3 2 1 3 2 2). Design procedures element-of-set?, adjoin-set, union-set, and 
; intersection-set that operate on this representation. How does the efficiency of each compare with the corresponding procedure for
; the non-duplicate representation? Are there applications for which you would use this representation in  preference to the non-
; duplicate one?
; ====
; The major shift here is that checking whether an element is part of a set will take longer, potentially much longer, but we will
; do that less often. The funny thing is that the performance of element-of-set? will vary not with the number or elements in the
; set, but with the number of elements in the internal representation of the set. Or rather, with how often we've called adjoin-set.
; If we run (adjoin-set 'a small-set) twenty times and small-set is empty when we start, small-set will have only one element, but
; element-of-set will have to check twenty elements each time.

; In adjoin-set, we no longer need to check whether an element is part of the target set before adding it, which means our 
; procedure is just a wrapper for cons. This is obviously faster than the previous version.
(define (adjoin-set x set)
	(cons x set))

; Union-set can speed up, too. We could stick with using adjoin-set to recursively move each element of one set to the other. This
; would be faster in some cases because adjoin-set is now faster. However it would be slower in other cases because the internal 
; representation of the set would be larger, so we would have more calls to adjoin-set. Instead, we'll just append the two, makeing
; union-set one operation, however large the internal representaitons of set1 and set2 are.
(define (union-set set1 set2)
	(append set1 set2))

; So those are the two procedures that speed up. Now we'll do the ones that slow down.
; The implementation of element-of-set? doesn't change at all. We still need to go through all elements of the set to see if
; the element we're looking for is there. The difference now is that there are potentially a lot more elements to go through
; and the number of operations will vary not with the size of the set, but with how many times we've called adjoin-set. The best
; case is that each call to adjoin-set added a unique element, in which case we see no performance change. Each duplicate element
; degrades performance. It is still an O(n) operation, but n is now how many times we've tried to add any element to the set. The 
; impact of this will be greatest when the element x is not in the set, or when it has not been added as frequently or as recently
; as the other elements in the set (so you have to search longer to find it).
(define (element-of-set? x set)
	(cond ((null? set) false)
		((equal? x (car set)) true)
		(else (element-of-set? x (cdr set)))))

; We also have the same implementation for intersection-set. It, too, is potentially much slower due to two factors. First, it relies
; on element-of-set? which, as we discussed above, is potentially much slower if set2 has many duplicate elements. Second, it checks
; element-of-set? for every element in the representation of set1, not just the unique elements in set1, so this part will be slow
; if set1 has many duplicate elements. 
(define (intersection-set set1 set2)
	(cond ((or (null? set1) (null? set2)) '())
		((element-of-set? (car set1) set2)
			(cons (car set1) 
				(intersection-set (cdr set1) set2)))
		(intersection-set (cdr set1) set2)))

; When might we use this? When we're confidant that, in practice, there will be no (or very) few duplicate elements. Perhaps if the
; sets are created by reading out of some other source (a file, a database) that's relatively clean. After all, element-of-set?
; and adjoin-set? don't necessarily perform worse with set representations that allow non-distinct elements. Only when there are,
; in fact, non-distinct elements. So something like reading out of a clean source, where we add elements to the set enought to make
; the performance gains in adjoin-set and union-set worth it, but are confidant we're not adding duplicate elements that would
; degrade element-of-set? or intersection-set.


