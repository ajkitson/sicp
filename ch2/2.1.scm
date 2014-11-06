; Define a better version of make-rat that handles both positive and negative arguments. Make-rat should normalize the sign so that if 
; the rational number is positive, both the numerator and denominator are positive, and if the rational number is negative, only the 
; numerator is negative.
; ====
; So, d is always positive and we flip the value of n iff d is negative. So, if d < 0 , n = n * -1 and d = d * -1.
; I'm assigning a factor (either 1 or -1) depending on the value of d. This means that I'm multiplying by 1 a good chunk of the time
; and that feels kind of dumb, but it consolidates the check in one place so I'll stick with it for now.

(define (make-rat n d)
	(let ((g (gcd n d))
		(sign (if (< d 0) -1 1))) ; if d < 0, flip the sign for n and d, otherwise not
	(cons (/ (* n sign) g) 
		(/ (* d sign) g))))

; And it works!
1 ]=> (make-rat 2 3)
;Value 5: (2 . 3)

1 ]=> (make-rat 3 -4)
;Value 6: (-3 . 4)

1 ]=> (make-rat -4 5)
;Value 7: (-4 . 5)

1 ]=> (make-rat -5 -9)
;Value 8: (5 . 9)

