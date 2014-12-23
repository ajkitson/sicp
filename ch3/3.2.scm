; In software testing application, it is useful to be able to count the number of times a given procedure is called during the course
; of a computation. Write a procedure make-monitored that takes as input a procedure f that itself takes one input. That result returned
; by make-monitored is a third procedure, say mf, that keeps track of the number of times it has been called by maintaining an 
; internal counter. If the input to mf is the special symbol how-many-calls?, then mf returns the value of the counter. If the input is 
; the special symbol reset-count, then mf resets the count to zero. For any other input mf returns the result of calling f on that
; input and increments the counter. For instance, we could amke a monitored version of the sqrt procedure:

; (define s (make-monitored sqrt))
; (s 100)
; 10
; (s 'how-many-calls?)
; 1

(define (make-monitored f)
	(let ((cnt 0))
		(lambda (arg)
			(cond 
				((eq? 'how-many-calls? arg) cnt)
				((eq? 'reset-count arg) (set! cnt 0))
				(else (set! cnt (+ cnt 1))
					  (f arg))))))
					  
1 ]=> (define s (make-monitored sqrt))
;Value: s

1 ]=> (s 100)
;Value: 10

1 ]=> (s 49)
;Value: 7

1 ]=> (s 'how-many-calls)
;Value: 2

1 ]=> (s 64)
;Value: 8

1 ]=> (s 'how-many-calls?)
;Value: 3

1 ]=> (s 'reset-count)
;Value: 3

1 ]=> (s 'how-many-calls?)
;Value: 0					  