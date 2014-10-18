; The process that a procedure generates is of course dependent on the rules used by the interpreter. As an example
; consider the iterative gcd procedure given below. Suppose we were to interpret this procedure using normal order
; evaluation. Using the substitution method, illustrate the process generated in evaluating (gcd 206 40) and 
; indicate the remainder operations that are actually performed. How many remainder operations are actually performed
; in normal order evaluation? In applicative-order evaluation?
;
; Here's the gcd procedure:
(define (gcd a b)
	(if (= b 0)
		a
		(gcd b (remainder a b))))

; Recall that normal order evaluation is when we expand the procedures until we have only primitives
; and then evaluate everything, whereas with applicative-order we fully evaluate an expression upon 
; passing it as an argument
;
; As described in Ex 1.5, the condition clause of if evaluates fully in order to decide which consequent to evaluate,
; so we're ignoring the condition clause during the substitution
;
; Normal-order evaluation:
(gcd 206 40) ; 206 % 40 = 6, therefore:
(gcd 40 (remainder 206 40)) ; 40 % 6 = 4, therefore: 

(gcd (remainder 206 40) 
	 (remainder 40 
	 			(remainder 206 40))) ; 6 % 4 = 2, therefore:

(gcd (remainder 40 
				(remainder 206 40)) 
	 (remainder (remainder 206 40) 
	 			(remainder 40 (remainder 206 40)))) ; 4 % 2 = 0, so we evaluate:

(gcd (remainder 40  ; replace (remainder 206 40) with 6
				6) 
	 (remainder 6 
	 			(remainder 40 6)))

(gcd 4 (remainder 6 4))
(gce 4 2) => 2

Total remainder operations: 6 (3 unique)


; applicative-order evaluation
(gcd 206 40)
(gcd 40 (remainder 206 40))
(gcd 40 6)
(gcd 6 (remainder 40 6))
(gcd 6 4)
(gcd 4 (remainder 4 6))
(gcd 4 2) => 2

Total remainder operations: 3 (only the uniqe ones)