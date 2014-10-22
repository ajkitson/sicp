; The smallest-divisor procedure shown at the start of this section sdoes lots of needless testing: Afater it checks
; to see if the number is divisible by 2 there is no point in testing whether it is divisible by larger even numbers.
; This suggests that the values for test-divisor should not be 2, 3, 4, 5, 6 ..., but rather 2, 3, 5, 7, 9,... 
; To implement this change, define a proceudre next that returns 3 if its input is equal to 2 and otherwise returns
; its input plus 2. Modify the smallest-divisor procedure to use (next test-divisor) instead of (+ test-divisor 1).
; With timed-prime-test incorporating this modified version of smallest-divisor, run the tests from ex 1.22. Since 
; the modification halves the number of test steps you should expect it to run about twice as fast. Is this exectation
; confirmed? If not, explain.

(define (smallest-divisor n)
	(define (next n)
		(if (= n 2) 3 (+ n 2)))
	(define (smallest-divisor-iter n test) 
		(cond ((< n (square test)) n) ; n is its own smallest divisor if none found less than sqrt(n)
			((= (remainder n test) 0) test)
			(else (smallest-divisor-iter n (next test)))))
	(smallest-divisor-iter n 2))

; Data is below. The times are more like 2/3 of the time it took before to figure out a given n was prime:
; .04 became .03 or .02,  (75% fo the earlier time)
; .11 became .07, (63%)
; .38 became .22. (57%)
; Why not 1/2 the time? Maybe because the time window doesn't just include trying to find a divisor but also
; the overhead of calculating timings, calling functions not related to the divisors, etc. There isn't a lot of this, 
; but notice that the percentages get smaller as the primes get larger and, correspondingly, calculating divisors will 
; take up a greater portion of the process' time. I don't find this super convincing, but I'm OK not getting to the 
; bottom of it.

1 ]=> (search-for-primes 1000000000 1000000100)
1000000007 *** .01999999999998181
1000000009 *** .03
1000000021 *** .03


1 ]=> (search-for-primes 10000000000 10000000100)
10000000019 *** .06999999999999318
10000000033 *** .0800000000000125
10000000061 *** .06999999999999318

1 ]=> (search-for-primes 100000000000 1000000000100)
100000000003 *** .24
100000000019 *** .22999999999999998
100000000057 *** .22999999999999998
