; Define a procedure reverse that takes a list as argument and returns a list of the same elements in reverse order.
; ==== 
; Quick and simple:

(define (reverse items)
	(define (iter source target)
		(if (null? source)
			target
			(iter (cdr source) (cons (car source) target))))
	(iter items (list)))

1 ]=> (reverse (list 1 2 3))
;Value 6: (3 2 1)