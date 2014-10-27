; Demonstrate that the Carmicheal numbers listed in footnote 47 really do fool the Fermat test. That is, write a procedure
; that takes an integer n and tests whether a^n is congruent to a mudulo n for every a < n, and try your proceure on the
; the given Carmicheal numbers.

; You can run this test calling (carmichael-test n) for the numbers listed in footnote 47.
; Or you can call find-carmichaels-below and it will find all numbers that pass the fermat test but are not 
; actually prime:

1 ]=> (find-carmichaels-below 7000)

6601 carmichael     
2821 carmichael
2465 carmichael
1729 carmichael
1105 carmichael
561 carmichael
done!

; ========
; We'll start out with expmod from previous exercises:
(define (expmod base exp m)
	(cond ((= exp 0) 1)
		((even? exp) 
			(remainder (square (expmod base (/ exp 2) m)) 
				m))
		(else 
			(remainder (* base (expmod base (- exp 1) m)) 
				m))))


; Find Carmichael numbers by running fermat test on all ints < n
(define (carmichael-test n)
	(define (one-fermat-test n m) ; just perform test once with given number m
		(= (expmod m n n)
			m))
	(define (carmichael-loop count)
		(cond ((= count 0) #t) ; must be either prime or carmichael if we made it this far
			((one-fermat-test n count) (carmichael-loop (- count 1)))
			(else #f)))
	(carmichael-loop (- n 1)))

; find carmichael numbers below n
(define (find-carmichaels-below n)
	(define (find-carmichaels-iter n)
		(define (print-n-recurse msg)
			(newline)
			(display n)
			(display msg)
			(find-carmichaels-iter (- n 1)))			
		(cond 
			((= n 0) (newline) (display "done!"))
			((and (carmichael-test n) (not (prime? n)))
				(print-n-recurse " carmichael"))
			(else (find-carmichaels-iter (- n 1)))))
;			(else (print-n-recurse " not carmichael"))))
	(find-carmichaels-iter (- n 1)))

; prime test carmichael numbers can't fool
(define (prime? n)
	(define (smallest-divisor n)
		(define (smallest-divisor-iter n test) 
			(cond ((< n (square test)) n) ; n is its own smallest divisor if none found less than sqrt(n)
				((= (remainder n test) 0) test)
				(else (smallest-divisor-iter n (+ test 1)))))
		(smallest-divisor-iter n 2))
	(= (smallest-divisor n) n))


