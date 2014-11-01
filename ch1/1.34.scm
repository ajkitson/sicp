; Suppose we define the procedure:

(define (f g)
	(g 2))

; Then we have:
(f square)
4

(f (lambda (z) (* z (+ z 1))))
6

; What happens if we (perversely) ask the intepreter to evaluate the combination (f f)?
; ====
; We get an error because you can't treat 2 as a procedure, which is what (f f) tries to do. How does this arise?
; Because (f f) => (f 2) => (2 2)
; 
; And to confirm, here's the output we get:
1 ]=> (define (f g) (g 2))
;Value: f

1 ]=> (f square)
;Value: 4

1 ]=> (f (lambda (z) (* z (+ z 1))))
;Value: 6

1 ]=> (f f)
;The object 2 is not applicable.
