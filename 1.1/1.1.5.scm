; Ben Bitdiddle has invented a test to determine whether the interpreter he is faced with is using applicative-order
; evaluation or normal-order evaluation. He defines the following two procedures:

; (define (p) (p))
; (define (test x y)
; 	(if (= x 0)
; 		0 
; 		y))

; Then he evaluates the expression 
; (test 0 (p))

; What behaviour will Ben obseve with an interpreter that uses applicative-order evaluation? What about normal-order 
; evaluation? Explain.
;
; ====
; The key difference is in whether we try to evaluate (p). Ben defined p so that it'll call itself infinitely, since
; it returns the evaluation of itself, which returns the evaluation of itself, etc.
;
; With applicative-order, we evaluate p in the first step, when we evaluate the operator and operands:
(if (= 0 0) 
	0
	???)
; Because we can't resolve (p), it never returns a value, even though it doesn't need to know (p)
;
; With normal-order evaluation, however, (p) doesn't get evaluated. We start by 
; expanding the test procedure:
(if (= 0 0)
	0
	(p))
=> 0
; since (= 0 0) , we never need to evaluate (p) and it will return 0, as it should.