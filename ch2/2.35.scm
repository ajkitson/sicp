; Redefine count-leaves from section 2.2.2 as an accumulation
; (define (count-leaves t)
; 	(accumulate
; 		??
; 		??
; 		(map ?? ??))
; ====
; Here we go. We're replacing each item in the tree with a number representing how many leaves it has (1 if it's a leaf, the 
; sum of it's leaves if it's not) and then counting them up
; 
(define (count-leaves t)
	(accumulate
		+
		0
		(map (lambda (x) (if (not (pair? x)) 1 (count-leaves x))) t)))

; Here's another way, where more of the burden is on the accumulate function. If the template hadn't prompted me to use map on
; the input sequenct, this is probably what I'd have ended up with.
(define (count-leaves t)
	(accumulate
		(lambda (node total) 
			(+ total (if (not (pair? node)) (count-leaves node) 1)))
		0
		t))

; This, though, is clearer to me than either of the above:
(define (count-leaves t)
	(length (fringe t))) ; flatten the tree and then get its length
