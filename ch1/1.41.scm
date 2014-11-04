; Define a procedure double that takes a procedure of one argument as argument and returns a procedure that applies the original procedure
; twice. For example, if inc is a procedure that adds 1 to its argument, then (double inc) should be a procedure that adds 2. What value
; is returned by (((double (double double)) inc) 5)?
; ====
; Let's see, I'd expect it to add 8 since we're applying double 3 times and 2 cubed is 8, but let's just write it up and see
(define (double f)
	(lambda (x)
		(f (f x))))

1 ]=> (((double (double double)) inc) 5)
;Value: 21

; Huh. We actually add 16. How's that? Well, it's because there's a difference between this and what we have above:
1 ]=> ((double (double (double inc))) 5)
;Value: 13

; The grouping really matters. With (double double), turn a function that doubles into one the quadruples. When we call double 
; on this procedure, we quadruble twice, so basically apply the function 16 times. That's where we get the +16.