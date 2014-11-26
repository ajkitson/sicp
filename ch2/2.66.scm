; Implement the lookup procedure for the case where the set of records is structured as a binary tree, ordered by the numerical values
; of the keys.
; ======
; The lookup procedure is supposed to operate on records in a database. So instead of comparing elements directly as we did in 
; earlier exercises, we use the key selector to retrieve the comparison value from a record. Otherwise, this is just like 
; element-of-set? except we return the record when we find it instead of true.
; The text doesn't describe exactly how thi

(define (lookup search-key record-tree)
	(if (null? record-tree)
		false
		(let ((record (entry record-tree)))
			(let ((this-key (key record)))
				(cond
					((equal? search-key this-key) record)
					((< search-key this-key (left-branch record-tree)))
					((> search-key this-key (right-branch record-tree))))))))
