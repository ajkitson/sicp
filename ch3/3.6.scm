; It is useful to be able to reset the random number generator to produce a sequence starting from a given value. Design a new rand
; procedure that is called with an argument that is either the symbol generate or the symbol reset and behaves as follows:
; (rand 'generate) produces a new random number; ((rand 'reset) <new value>) resets the internal state variable to the designated
; new value. Thus by resetting the state, one can generate repeatable sequences. These are vary handy to have when testing and 
; debugging programs that use random numbers.
; =====
; Since we don't have implementations of random-init or random-update, we'll just mock up some simply placeholders. They'll at least
; let us know we can generate the next number in the sequence and reset the sequence as needed, even if the sequence isn't 
; actually random (or even look like it)

(define random-init 0)
(define (random-update n) (+ n 1)) ; nobody will figure this out!

(define rand
	(let ((seed random-init))
		(lambda (op . val)
			(cond 
				((eq? op 'reset)
					(set! seed (car val)))
				((eq? op 'generate)
					(set! seed (random-update seed))
					seed)
				(else (error "Called rand with invalid operation -- RAND" (list op val)))))))

; And here it is in action:
1 ]=> (rand 'generate)
;Value: 1
1 ]=> (rand 'generate)
;Value: 2
1 ]=> (rand 'generate)
;Value: 3
1 ]=> (rand 'generate)
;Value: 4
1 ]=> (rand 'generate)
;Value: 5

1 ]=> (rand 'reset 2)
1 ]=> (rand 'generate)
;Value: 3
1 ]=> (rand 'generate)
;Value: 4
1 ]=> (rand 'generate)
;Value: 5
1 ]=> (rand 'generate)
;Value: 6
1 ]=> (rand 'generate)