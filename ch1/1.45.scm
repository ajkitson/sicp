; We saw in section 1.3.3 that attempting to compute square roots by naively finding a fixed point of y -> x/y does not converde, and
; that this can be fixed by average damping. The same method words for finding cube roots as fixed points of the average-damped 
; y -> x / y^2. Unfortunately, the process does not work for fourt roots--a single average damp is not enough to amke a fixed point 
; search for y -> x/y^3 converge. On the othe hand, if we average-damp twice (i.e. use the average damp of the average damp of y -> x/y^3)
; the fixed point search does converge. Do some experiments to determin how many average damps are requiredto compute nth roots as a 
; fixed point search based on repeated averge damping of y -> x/y^(n - 1). Use this to implement a simple procedure for computing nth
; roots using fixed-point, average-damp, and the repeated procedure of exercise 1.43. Assume that any arithmetic operations you need 
; are available as primitives.
; ====
; Let's start with a procedure that'll work for cube roots and we can expand from there...
(define (cube-root x)
	(fixed-point 
		(average-damp 
			(lambda (y) (/ x (* y y))))
		1.0))

; Now let's do y^4, using repeated on average-damp
(define (fourth-root x)
	(fixed-point 
		((repeated average-damp 2)
			(lambda (y) (/ x (* y y y))))
		1.0))

; OK, now let's play around with nth roots and see how much average damping we need to do
(define (nth-root x n)
	(fixed-point 
		((repeated average-damp 2) ; leaving hard-coded for now
			(lambda (y) (/ x (expt y (- n 1))))) ; is expt considered a primitive? It comes for free in mit-scheme. I'm not going to worry about it
		1.0))

; Played around with two average damps to see how far that would get me:
1 ]=> (nth-root 32 5)
;Value: 1.9999939482000786

1 ]=> (nth-root 64 6)
;Value: 1.9999765338190074

1 ]=> (nth-root 128 7)
;Value: 2.00003550080908

1 ]=> (nth-root 256 8)
^C

; So it seems we need an average damp each time we get to a new power of 2. Totally unscientific. Let's do something a little better
(define (test-roots base damps)
	(define (nth-root x n)
		(fixed-point 
			((repeated average-damp damps)
				(lambda (y) (/ x (expt y (- n 1))))) ; is expt considered a primitive? It comes for free in mit-scheme. I'm not going to worry about it
			1.0))
	(define (iter n)
		(newline)
		(display "Exponent ")
		(display n)
		(display "	")
		(display (nth-root (expt base n) n)) ;this will stall out when damps is no longer sufficient, or we'll see the values go off
		(iter (+ n 1)))
	(iter 0))

; Ran test-roots with a few bases and damps. Output is below. Whatever the base, we stall out at for roots of 2^(damps+1). So one damping gets us to cubed root.
; Two dampings gets us up to 7. 3 gets us to 15. 4 Gets us to 31, and so on. Having too many dampings does make you a less
; accurate, so we don't want to add them where we don't need them.

; Let's incorporate this into the FINAL PROCEDURE:
	(define (nth-root x n)
		(define (damping-count k)
			(if (< n (expt 2 (+ k 1)))
				k
				(damping-count (+ k 1))))
		(fixed-point 
			((repeated average-damp (damping-count 0))
				(lambda (y) (/ x (expt y (- n 1))))) ; is expt considered a primitive? It comes for free in mit-scheme. I'm not going to worry about it
			1.0))

; And it works! Even for the 140th root:
1 ]=> (nth-root (expt 12 140) 140)
;Value: 11.999997584899777


; Here's some sample output from test-roots
1 ]=> (test-roots 10 3)

Exponent 0	1.
Exponent 1	9.999313225321895
Exponent 2	10.000233729222995
Exponent 3	10.000108500962206
Exponent 4	10.000090913597067
Exponent 5	10.00002642408991
Exponent 6	10.00002124403458
Exponent 7	10.000009388411495
Exponent 8	10.000000000334943
Exponent 9	9.99999773418768
Exponent 10	9.999992547249386
Exponent 11	9.999976149475895
Exponent 12	9.999977083627478
Exponent 13	10.000034069428132
Exponent 14	10.000036454461132
Exponent 15	9.999955945903157
Exponent 16	^G
;Quit!

1 ]=> (test-roots 10 4)
Exponent 0	1.
Exponent 1	9.998519648584129
Exponent 2	9.999315487812469
Exponent 3	10.000408933758436
Exponent 4	10.000260676802368
Exponent 5	10.00015869231435
Exponent 6	10.000108689177102
Exponent 7	10.000090085262892
Exponent 8	10.000070713124945
Exponent 9	10.000039048439703
Exponent 10	10.000027720635714
Exponent 11	10.00002632280844
Exponent 12	10.000008866907955
Exponent 13	10.000013975122716
Exponent 14	10.00000454587834
Exponent 15	10.000000795611012
Exponent 16	10.000000000954518
Exponent 17	9.999995505618426
Exponent 18	10.00000304246359
Exponent 19	9.999992724112136
Exponent 20	10.000008980035359
Exponent 21	9.999983739363078
Exponent 22	9.999989590234815
Exponent 23	10.000021658858332
Exponent 24	9.99998305565091
Exponent 25	10.000022142528003
Exponent 26	9.999969864252346
Exponent 27	9.999964043659828
Exponent 28	9.999962010696937
Exponent 29	9.999961811747452
Exponent 30	10.000045686712365
Exponent 31	10.000047512302649
Exponent 32	^G
;Quit!



; Below is code reused from previous exercises
(define (fixed-point f first-guess)
	(define (close-enough? v1 v2)
		(< (abs (- v1 v2)) 0.0001))
	(define (try guess)
		(let ((next (f guess)))
			(if (close-enough? guess next)
				next
				(try next))))
	(try first-guess))

(define (average-damp f)
	(lambda (x) (/ (+ x (f x)) 2)))

(define (compose f g) 
	(lambda (x) (f (g x))))

(define (repeated f n)
	(if (= n 1)
		f
		(compose f (repeated f (- n 1)))))

