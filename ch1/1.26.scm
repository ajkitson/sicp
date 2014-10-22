; Louis Reasoner is having great difficulty doing exercise 1.24. His fast-prime? test seems to run more slowly 
; than his prime? test. Louis calls his friend Eva Lu Ator over to help. When they examine Louis' code, they find that
; he has rewritten the expmod procedure to use an explicit multiplication, rather than calling square:

(define (expmod base exp m)
	(cond ((= exp 0) 1)
		((even? exp) 
			(remainder (* (expmod base (/ exp 2) m)
						  (expmod base (/ exp 2) m)) 
						m))
		(else (remainder (* base 
							(expmod base (- exp 1) m)) 
						m))))

; "I don't see what difference it could make," says Louis. "I do." says Eva. "By writing the procedure like that, you
; have transformed the O(logn) process into an O(n) process." Explain.
; ======
; Ah, Louis. Let's revisit applicative-order evaluation. Suppose we have a simple procedure that returns a number: 
(define (simple n)
	(+ n 1))
; Now, the difference between this:
(square (simple n))
; and this:
(* (simple n) (simple n))
; is that in the first case we call our simple procedure once and then square it's return value, whereas in the second
; case we call simple twice and then multiple the return values. This isn't super important for our simple procedure, but
; if we do the same thing on a recursive procedure like expmod, then we introduce an unnecassary branch with each
; recursive call. 
;
; Recall the in fast-prime?, we pass the number we're testing for primality to expmod as exp. Now, if we use the 
; square procedure, expmod runs in O(logn) because we're able to halve exp at each call. However, the way Louis
; wrote expmod, although we halve exp in calling expmod recursively, we call expmod recursively twice so there 
; is no gain and we're back to an O(n) process.