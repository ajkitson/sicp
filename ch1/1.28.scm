; One variant of the Fermat test that cannot be fooled is the Miller-Rabin test. This starts from an alternate form of
; Fermat's Little Theorem, which states that if n is a prime number and a is any positive integer less than n, then 
; a^(n - 1) is congruent to 1 modulo n.
;
; To test the primality of a number n by the Miller-Rabin test, we pick a random number a < n and raise a to the (n - 1)
; power modulo n using the expmod procedure. However, when we perform the squaring step of expmod, we check to see if 
; we have discovered a "non-trivial square-root of 1 modulo n," that is, a number not equal to 1 or n - 1 whose square is
; equal to 1 modulo n. (ajk, note to self: to clarify, this means: ((whose square) % n) = (1 % n) = 1, the modulo n applies 
; to the entire equation, both sides... I find this terminology terribly confusing. More natural once you remember that we're 
; with modular arithmetic http://en.wikipedia.org/wiki/Modular_arithmetic)
;
; It is possible to prove that if such a nontrivial square root of 1 exists, then n is not prime. It is also possible to 
; prove that if n is odd and not prime, then, for at least half the numbers a < n, computing a^(n - 1) in this way will 
; reveal a nontrivial square root of 1 modulo n. (This is why the Miller-Rabin test cannot be fooled.) 
; 
; Modify the expmod procedure to signal if it discovers a nontrivial square root of 1, and use this to implement the 
; Miller-Rabin test with a procedure analagous to fermat-test. Check your procedure by testing various known primes and 
; non-primes. Hint: one convenient way to make expmod signal is to have it return 0.
;
; =====
; Let's get a feel for how this test works with some examples. 
; We'll start with n = 5. Since 5 is prime, we expect every number 1 ... 4 taken to the 4th power to have a remainder 
; of 1 when divided by 5:
; a = 4, 4 ^ 4 = 256, 256 % 5 = 1
; a = 3, 3 ^ 4 = 81, 81 % 5 = 1
; a = 2, 2 ^ 4 = 16, 16 % 5 = 1
; a = 1, 1 ^ 4 = 1, 1 % 5 = 1
; 
; That works out. Now let's consider a non-prime example: n = 4. We expect some number 1..3, when cubed and then divided
; by 4 to have a remainder other than 1:
; a = 3, 3 ^ 3 = 27, 27 % 4 = 3
; a = 2, 2 ^ 3 = 8, 8 % 4 = 0
; a = 1, 1 ^ 3 = 1, 1 % 4 = 1 << this is OK since there are other values for which a ^ (n -1) % n !== 1
;
; The key points in this, once you understand how the test works, is to see that you need to put the check in a new procedure
; that handles checking whether we've got a non-trivial sqrt of 1 mod n. If you don't do this, you end up having to call expmod
; multiple times and kicking off the recursion more than you should, like Louis did in exercise 1.26.
; From there, it's pretty straightforward (as long as you get your parentheses right):

; returns if n squared % n is 1, then we return 0, otherwise n squared % m (which might also be 0)
(define (sq-mod-check-sqrt1 n m)
	(if (and (not (or (= n 1) (= n (- m 1))))  ;n !== 1 or m, and
		(= 1 (remainder (* n n) m)))	 ; n squared % m == 1 >> we have a non-trivial sqrt of 1 mod m
		0
		(remainder (* n n) m)))

(define (expmod base exp m)
	(cond ((= exp 0) 1)
		((even? exp) 
			(sq-mod-check-sqrt1
				(expmod base (/ exp 2) m)  
				m))
		(else 
			(remainder (* base (expmod base (- exp 1) m)) 
				m))))

(define (fast-prime? n times)
	(define (mr-test n)
		(define (try-it a)
			(= (expmod a (- n 1) n) 1)) ; a^(n - 1) % n == 1
		(try-it (+ 2 (random (- n 2))))) ; avoid passing 1 since it's a false positive, from the comments: http://www.billthelizard.com/2010/03/sicp-exercise-128-miller-rabin-test.html
	(cond ((= times 0) true)
		((mr-test n) (fast-prime? n (- times 1)))
		(else false)))

(define (prime-check-loop n)
	(newline)
	(cond ((< n 3) ; because we haven't built in handling for 0, 1, 2
		(display "DONE!"))
		(else
			(display n)
			(display (if (fast-prime? n 10) " - prime" " - not prime"))
			(prime-check-loop (- n 1)))))


1 ]=> (prime-check-loop 100)

100 - not prime
99 - not prime
98 - not prime
97 - prime
96 - not prime
95 - not prime
94 - not prime
93 - not prime
92 - not prime
91 - not prime
90 - not prime
89 - prime
88 - not prime
87 - not prime
86 - not prime
85 - not prime
84 - not prime
83 - prime
82 - not prime
81 - not prime
80 - not prime
79 - prime
78 - not prime
77 - not prime
76 - not prime
75 - not prime
74 - not prime
73 - prime
72 - not prime
71 - prime
70 - not prime
69 - not prime
68 - not prime
67 - prime
66 - not prime
65 - not prime
64 - not prime
63 - not prime
62 - not prime
61 - prime
60 - not prime
59 - prime
58 - not prime
57 - not prime
56 - not prime
55 - not prime
54 - not prime
53 - prime
52 - not prime
51 - not prime
50 - not prime
49 - not prime
48 - not prime
47 - prime
46 - not prime
45 - not prime
44 - not prime
43 - prime
42 - not prime
41 - prime
40 - not prime
39 - not prime
38 - not prime
37 - prime
36 - not prime
35 - not prime
34 - not prime
33 - not prime
32 - not prime
31 - prime
30 - not prime
29 - prime
28 - not prime
27 - not prime
26 - not prime
25 - not prime
24 - not prime
23 - prime
22 - not prime
21 - not prime
20 - not prime
19 - prime
18 - not prime
17 - prime
16 - not prime
15 - not prime
14 - not prime
13 - prime
