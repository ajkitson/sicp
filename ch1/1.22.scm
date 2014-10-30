; The following timed-prime-test procedure, when called with an integer n, prints n and checks to see if n is prime.
; it n is prime, the procedure prints three asterisks followed by the amount of time used in performing the test.

(define (smallest-divisor n)
	(define (smallest-divisor-iter n test) 
		(cond ((< n (square test)) n) ; n is its own smallest divisor if none found less than sqrt(n)
			((= (remainder n test) 0) test)
			(else (smallest-divisor-iter n (+ test 1)))))
	(smallest-divisor-iter n 2))

(define (prime? n)
	(= (smallest-divisor n) n))

(define (timed-prime-test n)
	(newline)
	(display n)
	(start-prime-test n (runtime)))

(define (start-prime-test n start-time)
	(if (prime? n)
		(report-prime (- (runtime) start-time))))

(define (report-prime elapsed-time)
	(display " *** ")
	(display elapsed-time))

; Using this procedure, write a procedure search-for-prime that checks the primality of consecutive odd integers in
; a specified range. use your procedure to find the 3 smallest primes larger than 1000; larger than 10,000; larger 
; than 100,000; larger than 1,000,000. Note the time needed to test each prime. Since the testing algorithm has order
; of growth of O(sqrt(n)), you should expect the testing for primes around 10,000 to take about sqrt(10) times as long 
; as testing for primes around 1000. Do your timings data bear this out? How well do the data for 100k and 1m support
; the sqrt(n) prediction? Is your result compatible with the notion that programs on your machine run in time proportional
; to the number of steps required for computations?
; =====
; note that this doesn't handle 2, but that's baked into the definition given the "consecutive odd integer" part
(define (search-for-primes start end)
	(if (<= start end)
		(cond ((even? start) 
				(search-for-primes (+ start 1) end))
			(else 
				(timed-prime-test start)
				(search-for-primes (+ start 2) end)))
		(display "done!")))

; Results on the 3 primes greater than 1000, 10k, and 1m are below. Not much to see here. Maybe computers got too fast
; for this question to make sense. There's no variation in time--everything comes in at 0.
; Had to go above 1billion to get any sort of readings (wow).
; 
; Here are the first 3 primes past 1 billion: 
1 ]=> (search-for-primes 1000000000 1000000100)
1000000007 *** .03999999999999204
1000000009 *** .04000000000000625
1000000021 *** .04000000000000625

; And here are the first 3 primes past 10 billion:
1 ]=> (search-for-primes 10000000000 10000000100)      
10000000019 *** .12000000000000455
10000000033 *** .10999999999999943
10000000061 *** .11000000000001364

; We expect to see 10n to take sqrt(10) times as long as n, and we do! 
; Let's check out 100b to confirm. We expect thest to be in the mid 0.3s
; ...and that's about what we get!
					  	    		  
1 ]=> (search-for-primes 100000000000 1000000000100)
100000000003 *** .38000000000000966
100000000019 *** .37000000000000455
100000000057 *** .39000000000000057

; ============
; Uninteresting results for 1k, 10k, 1m
1 ]=> (search-for-primes 1000 2000)
1001
1003
1005
1007
1009 *** 0.  << Prime
1011
1013 *** 0. << Prime
1015
1017
1019 *** 0. << Prime
...

1 ]=> (search-for-primes 10000 11000)
10001
10003
10005
10007 *** 0.  << Prime
10009 *** 0.  << Prime
10011
10013
10015
10017
10019
10021
10023
10025
10027
10029
10031
10033
10035
10037 *** 0.  << Prime

1 ]=> (search-for-primes 1000000 1001000)
1000001
1000003 *** 0.  << Prime
1000005
1000007
1000009
1000011
1000013
1000015
1000017
1000019
1000021
1000023
1000025
1000027
1000029
1000031
1000033 *** 0.  << Prime
1000035
1000037 *** 0.  << Prime



