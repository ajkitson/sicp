; Implement the constructor make-from-mag-ang in a message-passing style. This procedure should be analogous to the make-from-real-imag
; procedure given above.
; =======
; This is cool. Basically OO Scheme. The change is that we use constructors that, instead of returning a list or some other 
; representation of the object that other procedures can act on, returns a procedure. The procedure accepts "messages" asking it to
; perform operations on the data, which it is able to access via the closure and that is inaccessible to the client. 

(define (make-from-mag-ang mag ang)
	(define (dispatch op)
		(cond
			((eq? op 'real-part) (* mag (cos ang)))
			((eq? op 'imag-part) (* mag (sin ang)))
			((eq? op 'magnitude) mag)
			((eq? op 'angle) ang)
			(else (error "Passed unknown operator -- make-from-mag-ang" op))))
	dispatch)


1 ]=> (define cnum (make-from-mag-ang 5 (atan 3 4)))
1 ]=> (cnum 'magnitude)
;Value: 5
1 ]=> (cnum 'angle)
;Value: .6435011087932844
1 ]=> (cnum 'real-part)
;Value: 4.
1 ]=> (cnum 'imag-part)
;Value: 3.
1 ]=> (cnum 'nonsense)
;Passed unknown operator -- make-from-mag-ang nonsense
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.

