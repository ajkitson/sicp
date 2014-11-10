; Ben Bitdiddle, an expert systems progammer, looks over Alyssa's shoulder and comments that it is not clear what it means to divide
; by an interval that spans zero. Modify Alyssa's code to check for this condition and to signal an error if it occurs.

(define (div-interval a b)
	(if (and (< (lower-bound b) 0)
			(> (upper-bound b) 0))
		(error "Error: cannot divide by an interval that spans zero.")
		(mul-interval 
			a 
			(make-interval 
				(/ 1 (upper-bound b)) 
				(/ 1 (lower-bound b))))))
