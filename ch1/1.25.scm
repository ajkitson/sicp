; Alyssa P hacker complains that we went to a lot of extra work in writing expmod. After all, she says, since we already
; know how to compute exponentials, we could have simply written:

(define (expmod base exp m)
	(remainder (fast-exp base exp) m))

; Is she correct? Would this procedure serve as well for our fast prime test? Explain.
; 
; First, let's recall what fast-exp and the version of expmod that Alyssa is criticizing look like.
; Alyssa thinks this is unnecessarily complex:
(define (expmod base exp m)
	(cond ((= exp 0) 1)
		((even? exp) 
			(remainder (square (expmod base (/ exp 2) m)) 
				m))
		(else 
			(remainder (* base (expmod base (- exp 1) m)) 
				m))))

; This is what Alyssa thinks we should use (there's also an iterative version in 1.16)
(define (fast-exp b n)
	(cond ((= n 0) 1)
		((even? n) (square (fast-exp b (/ n 2))))
		(else (* b (fast-exp b (- n 1))))))

; Would this work? Sure it would. It would be as accurate as the more elaborate version of expmod. 
; Of course, correctness isn't the only concern. Would it perform as well? 
; 
; I have to admit that I was with Alyssa on this one when I first read it. I didn't understand the difference. After
; all, each takes the same number of steps. They're both O(logn), right? Then I ran some tests and the fast-exp 
; method is even slower than the prime test that doesn't use the Fermat test. Huh?
;
; Footnote 46 gives something of an exlanation. It points out that by taking the remainder at each step instead of
; after the exponentiation is finished we never have to deal with numbers much larger than m (what we're taking the 
; modulo of). Why does this matter? 
;
; Well, because we end up looking at some very large numbers. For example, if we're testing whether 10,000 is prime, 
; we take a random number less than 10,000 to the 10,000th power and then get the remainder. That's a huge number, even
; if the random number we choose is 2! When we get to numbers this size, we can't use a 32-bit integer anymore but need
; to switch to a larger representation and basic arithmetic operations slow way down. So by keeping the numbers small
; we're able to stay within the normal 32-bit integer and use our speedy math. 
; 
; This was an interesting one. I wasn't sensitive to how arithmetic slows down with big numbers, and since we spend a 
; lot of time looking at how the number of steps affects performance, I expected the difference to be some nuance in the 
; process that I had missed. Good to run up against another factor to consider with performance
