; Right-split and up-split can be expressed as instances of a general splitting operation. Define a procedure split with the property
; that evaluating 

; (define right-split (split beside below))
; (define up-split (split below beside))

; produces procedures right-split and up-split with the same behaviors as the ones already defined.

(define (split major-split minor-split)
	(define (split-internal painter n)
		(if (= n 0)
			painter
			(let ((smaller (split-internal (- n 1))))
				(major-split painter (minor-split smaller smaller)))))
	(lambda (painter n) 
		(split-internal painter n)))