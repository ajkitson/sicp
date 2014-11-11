; The procedure for-each is similar to map. It takes as arguments a procedure and a list of elements. However, rather than forming a
; list of the results, for-each just applies the procedureto each of the elements in turn, from left to right. The values returned
; by applying the procedure to the elements are not used at all--for-each is used with procedures that perform an action, such as 
; printing. For example,
; 1 ]=> (for-each (lambda (x) (newline) (display x)) (list 57 321 88))
; 57
; 321
; 88

; The value returned by the call to for-each (not illustrated above) can be something arbitrary such as true. Give an implementation
; of for-each.
; =====
; Very similar to map. here I use cond instead of if because we haven't covered how to evaluate multiple expressions in an if clause
; and I couldn't find a good way to incorporate the (f (car items)) call and the (for-each f (cdr items)) call into one expression.
(define (for-each f items)
	(cond 
		((null? items) true)
		(else
			(f (car items))
			(for-each f (cdr items)))))
