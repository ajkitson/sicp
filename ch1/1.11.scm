; A function f is defined by the rules that:
; - f(n) = n if n < 3, and 
; - f(n) = f(n - 1) + 2f(n - 2) + 3f(n - 3) if n >= 3.
; Write a procedure that computes f be means of a recursive process. Write a procedure that computes f by means of 
; an iterative process

; here's the recursive processs
(define (f-recur n)
	(if (< n 3)
		n
		(+ (f-recur (- n 1))
			(* 2 (f-recur(- n 2)))
			(* 3 (f-recur(- n 3))))))

; this one takes a bit more thinking. If we try to work backwards from n to n < 3, we get the 
; tree recursion, so not an iterative process. So instead, let's work up, building the result
; until we meet n. We can just track the previous three values of f(n) in args a, b, and c (c for current!)
(define (f-iter-internal a b c count) 
	(if (= count 0)
		c
		(f-iter-internal b
				c
				(+ (* 3 a) (* 2 b) c)
				(- count 1))))

(define (f-iter n)
	(if (< n 3)
		n
		(f-iter-internal 0 1 2 (- n 2))))
