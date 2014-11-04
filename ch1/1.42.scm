; Let f and g be two one argument functions. The composition f after g is defined to be the function x -> f(g(x)). Define a procedure
; compose that implements composition. For example, if inc is a procedure that adds 1 to its argument: 
; ((compose square inc) 6)
; 49
; ====
; This one is pretty easy. Just need to return a lambda that evaluates f(g(x)) for a given x.

(define (compose f g) 
	(lambda (x) (f (g x))))

; Does it work? Let's see:
1 ]=> ((compose square (lambda (x) (+ x 1))) 6)
;Value: 49


