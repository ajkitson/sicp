; Use the smallest-divisor procedre to find the smallest divisor of each of the following numbers: 
; 199, 1999, 19999
;
(define (smallest-divisor n)
	(define (smallest-divisor-iter n test) 
		(cond ((< n (square test)) n) ; n is its own smallest divisor if none found less than sqrt(n)
			((= (remainder n test) 0) test)
			(else (smallest-divisor-iter n (+ test 1)))))
	(smallest-divisor-iter n 2))

1 ]=> (smallest-divisor 199)
;Value: 199

1 ]=> (smallest-divisor 1999)
;Value: 1999


1 ]=> (smallest-divisor 19999)
;Value: 7

