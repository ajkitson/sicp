; Modify the timed-prime-test procedure of exerice 1.22 to use fast-prime? and test each the the primes you found in 
; that exercise. Since the Fermat test has O(log n) growth, how would you expect the time to test primes near 1 million
; to compare with the time needed to test primes near 1000? Do your data bear this out?
; =====
; Code is below. 
; I expect 1mil to take about twice as long as 1k since log 1mil = 6 and log 1k = 3. Of course, given that I have to 
; work with much higher numbers to get time readings, I'll have to scale this appropriately.
; =====
; Now that I'm actually testing it, all my previous tests are just showing zeros for times, which is awesome but doesn't
; help me answer the quesiton. Will have to go even larger numbers... but even when I get to 10^60, I'm still getting
; not getting timing info registered. Which, to some extent, makes sense, illustrating the difference between 
; O(log n) growth and O(n) (or even O(sqrt(n)))


(define (expmod base exp m)
	(cond ((= exp 0) 1)
		((even? exp) 
			(remainder (square (expmod base (/ exp 2) m)) 
				m))
		(else 
			(remainder (* base (expmod base (- exp 1) m)) 
				m))))

(define (fast-prime? n times)
	(define (fermat-test n)
		(define (try-it a)
			(= (expmod a n n) a))
		(try-it (+ 1 (random (- n 1)))))
	(cond ((= times 0) true)
		((fermat-test n) (fast-prime? n (- times 1)))
		(else false)))

(define (timed-prime-test n)	
	(define (start-prime-test n start-time)
		(if (fast-prime? n 5) ; 255 Carmichael numbers < 100,000,000. Odds of all 5 guesses being Carmichael numbers is super small
			(report-prime (- (runtime) start-time))))
	(define (report-prime elapsed-time)
		(display " *** ")
		(display elapsed-time))	
	(newline)
	(display n)
	(start-prime-test n (runtime)))

(define (search-for-primes start end)
	(if (<= start end)
		(cond ((even? start) 
				(search-for-primes (+ start 1) end))
			(else 
				(timed-prime-test start)
				(search-for-primes (+ start 2) end)))
		(display "done!")))