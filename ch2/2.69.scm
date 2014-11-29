; The following procedure takes as its argument a list of symbol-frequency pairs (where no symbol appears in more than on pair) and
; generates a Huffman encoding tree according to the Huffman algorithm.

(define (generate-huffman-tree pairs)
	(successive-merge (make-leaf-set pairs)))

; make-leaf-set is the procedure given above that transforms the list of pairs into an ordered set of leaves. successive-merge is the 
; procedure you must write, using make-code-tree to successively merge the smallest-weight elements of the set until there is only
; one element left, which is the desired Huffman tree. (This procedure is slightly tricky, but not really complicated. If you find 
; yourself designing a complex procedure, then you are almost certainly doing something wrong. You can take significant advantage
; of the fact that we are using an ordered set representation.)
; =======
; This actually seems pretty straightforward. We just get the two smallest pairs and combine them. We know that these are the 
; first two pairs because the set is ordered. We use adjoin-set to add the new pair to the set, which will maintain the order. When
; we only have one pair left, we're done--we've combined all the pairs. 

(define (successive-merge pairs)
	(if (null? (cdr pairs)) ; only one element left
		(car pairs)
		(successive-merge 
			(adjoin-set 	; join lowest two and add to set of pairs and merge the result
				(make-code-tree (car pairs) (cadr pairs)) 
				(cddr pairs)))))


; Here it is in action. We can now define sample-tree from 2.67 using generate-huffman and still get the same message when we 
; decode it:
1 ]=> (define sample-tree (generate-huffman-tree '((C 1) (D 1) (A 4) (B 2))))
;Value: sample-tree
1 ]=> (decode sample-message sample-tree)
;Value 12: (a d a b b c a)




; Supporting code from the text:
(define (adjoin-set x set)
	(cond ((null? set) (list x))
		((< (weight x) (weight (car set)))
			(cons x set))
		(else (cons (car set) (adjoin-set x (cdr set))))))

(define (make-leaf-set pairs)
	(if (null? pairs)
		'()
		(let ((pair (car pairs)))
			(adjoin-set
				(make-leaf (car pair) (cadr pair))
				(make-leaf-set (cdr pairs))))))
