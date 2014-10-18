; Design a procedure that evolves an iterative exponentiation process that uses successive squaring and takes a 
; logarithmic number of steps, as does fast-expt. 
; ===
; Let's start with the provided definition of fast-expt:
(define (fast-expt b n)
	(define (even? n) (= (remainder n 2) 0))
	(define (square n) (* n n))
	(cond ((= n 0) 1)
		((even? n) (square (fast-expt b (/ n 2))))
		(else (* b (fast-expt b (- n 1))))))

; For this exercise, we're making the above procedure iterative, but it'll help to step back and define the core 
; process that's happening.  Basically, we're observing that b^n = (b^n/2)^2. Our goal is to get n to 0. 
; For powers of 2, this works great and is a really quick way to get there. For non powers of 2, we're going 
; to hit an odd exponenet at some point. In that case, we get back to an even exponent by doing base * base^(n-1). 
; 
; Here's an iterative version. Instead of waiting the the deferred fast-expt calls to get the result, we're tracking
; the result in the variable sofar. At any given point, the result can be given by sofar * b^n
; 
(define (fast-expt b n)
	(define (even? n) (= (remainder n 2) 0))
	(define (square n) (* n n))
	(define (fast-expt-iter b n sofar)
		(cond ((= n 0) sofar) ;at this point, we've moved all value from b^n to sofar
			((even? n) (fast-expt-iter (square b) (/ n 2) sofar))
			(else (fast-expt-iter b (- n 1) (* sofar b)))))
	(fast-expt-iter b n 1))

