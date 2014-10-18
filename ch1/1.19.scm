; I'll summarize this one since the descrition is long.

; We're trying to compute fibonacci numbers in logarithmic time. The exercise describes a way of considering the fibonacci
; sequence as a certain transform that updates our values a and b that is applied n times, or T^n. After the transform
; is applied n times, fib(n) = b.

; Here is the transform of a and b: a <-- bq + aq + ap, and b <-- bp + aq

; If we stick with p = 0 and q = 1, this is basically saying a become a + b and b becomes a. 
; However, by using the transform we can use successive squaring to speed things up. If we want T^n, we 
; can compute T^2(T^n-2), and so forth. 

; Here's the question:
; Show that if we apply such a transform Tpq twice, the effect is the same as using a signle transform Tp'q' of the 
; same form, and compute p' and q' in terms of p and q. This gives us an explicit way to square these transformations
; and thus we can compute T^n using successive squaring as in the fast-expt procedure.

;======
; First, let's show that we can apply T twice and figure out p' and q'. We'll start with b since it'll be easiest
T(b) = bp + aq   ; (I know we don't really call T(b)... just saying that after one transform this is what we get...)
T(T(b)) = p(bp + aq) + q(bq + aq + ap)
		= bp^2 + apq + bq^2 + aq^2 + apq
		= bp^2 + bq^2 + aq^2 + 2apq 		(regrouping)
		= b(p^2 + q^2) + a(q^2 + 2pq)		(factor out a and b)

p' = p^2 + q^2
q' = q^2 + 2pq

; Let's confirm that this works transforming a
T(a) = bq + aq + ap
T(T(a)) = (bp + aq)q + (bq + aq + ap)q + (bq + aq + ap)p
		= bpq + aq^2 + bq^2 + aq^2 + apq + bpq + apq + ap^2
		= bq^2 + 2bpq + aq^2 + 2apq + ap^2 + aq^2
		= b(q^2 + 2pq) + a(q^2 + 2pq) + a(p^2 + q^2)

; This gives us the same values for p' and q', so we're set.
; Tested below and it works

(define (fib n)
	(fib-iter 1 0 0 1 n))

(define (fib-iter a b p q count)
	(cond ((= count 0) b)
		((even? count)
			(fib-iter a 
					  b 
					  (+ (square p) (square q)) ; p <-- p'
					  (+ (square q) (* 2 (* p q))) ; q <-- q'
					  (/ count 2))) ; successive square
		(else (fib-iter (+ (* b q) (* a q) (* a p))
						(+ (* b p) (* a q))
						p
						q
						(- count 1)))))