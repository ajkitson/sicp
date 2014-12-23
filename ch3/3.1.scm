; An accumulator is a procedure that is called repeatedly with a single numeric argument and accumulates its arguments into a sum. Each
; time it is called, it returns the currently accumulated sum. Write a procedure make-accumulator that generates accumulators, each 
; maintaining an independent sum. The input to make-accumulator should specify the initial value of the sum; for example:
;
; (define A (make-accumulator 5))
; (A 10)
; 15
; (A 10)
; 25

(define (make-accumulator tot)
	(lambda (inc)
		(set! tot (+ tot inc))
		tot))

; in action:

1 ]=> (define a (make-accumulator 10))
;Value: a

1 ]=> (a 5)
;Value: 15

1 ]=> (a 5)
;Value: 20

1 ]=> (a 5)
;Value: 25

1 ]=> (define b (make-accumulator 100))
;Value: b

1 ]=> (b 300)
;Value: 400

1 ]=> (b 300)
;Value: 700

1 ]=> (a 400)
;Value: 425