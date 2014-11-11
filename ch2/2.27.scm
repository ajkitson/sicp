; Modify your reverse procedure of exercise 2.18 to produce a deep-reverse procedure that takes a list as argument and returns as its value
; the list with its elements reversed and with all sublists deep-reversed as well. For example, 
;
; (define x (list (list 1 2) (list 3 4)))
;
; x
; ((1 2) (3 4))
;
; (reverse x)
; ((3 4) (1 2))
;
; (deep-reverse x)
; ((4 3) (2 1))
;
; ======
; The change is pretty simmple. We just test whether (car source) is a list. If it is, we reverse it before passing cons-ing it to
; our target. 

(define (deep-reverse items)
	(define (iter source target)
		(if (null? source)
			target
			(let ((next (car source)))
				(iter
					(cdr source)
					(cons 
						(if (pair? next) (deep-reverse next) next) ; if next val is a list, reverse it, too
						target)))))
	(iter items (list)))

; Here we go:

1 ]=> (define x (list (list 1 2) (list 3 4)))
1 ]=> x
;Value 28: ((1 2) (3 4))

1 ]=> (reverse x)
;Value 29: ((3 4) (1 2))

1 ]=> (deep-reverse x)
;Value 30: ((4 3) (2 1))