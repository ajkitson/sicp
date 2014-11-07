; Show that we can represent pairs of nonnegative integers using only numbers and arithmetic operations if we represent the pair a and b
; as the integer that is the product of 2^a and 3^b. Give the corresponding definitions of the procedures cons, car, and cdr.
; =====
; Another fun one. 
; How does this work? I'll sketch the general outline and not do a full proof. 
; The main idea is that any given product of a power of two and a power of 3 factors to only one possible power of two and only
; one possible power of three. (Contrast this with a number like 12, which you can get from 3 x 4 and 2 x 6) 
; How do we know this is true?
; Well, consider that all powers of two are even (even x even = even) and all powers of three are odd (odd x odd = odd).
; If the product is even, we know that one or more powers of 2 is in it. We know that we could not have ended up with that 
; product by taking powers of 3 alone. So we divide by 2 and get a new number to evaluate. If this is even, then we again
; know that there must be another product of 2 in it, so we divide by two and get a new number. 
; Now at some point, we get to an odd number (which might be 1). At this point, we know that no power of two (other than 0) could
; have produced this number, so this number must be a power of three.
; Because there is only one way to attribute the contribution of the powers of two and the powers of 3, we must be able to factor
; or product into unique powers of two and powers of 3. 
; 
; Enough words. Let's write some code:
(define (cons a b)
	(* a b))

(define (reduce n factor result)
	(if (= (remainder n factor) 0)
		(reduce (/ n factor) factor (+ result 1))
		result))

(define (car p)
	(reduce p 2 0))

(define (cdr p)
	(reduce p 3 0))

; Huh, that was a bit simpler than I thought it'd be. Let's see if it works:
1 ]=> (define p (cons 123 789))
;Value: p

1 ]=> (car p)
;Value: 123

1 ]=> (cdr p)
;Value: 789

; Woot!