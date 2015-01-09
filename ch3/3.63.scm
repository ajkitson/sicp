; Louis Reasoner asks why the sqrt-stream procedure was not written in the following more straightforward way, without the local variable
; guesses:

; (define (sqrt-stream x)
;     (cons-stream 1.0
;                  (stream-map (lambda (guess)
;                                 (sqrt-improve guess x)
;                                 (sqrt-stream x)))))

; Allysa P. Hacker replies that this version of the procedure is considerably less efficient because it performs redundant computation.
; Explain Alyssa's answer. Would the two versions still differ in efficiency if our implementation of delay used only (lambda () <exp>)
; without using the optimization provided by memo-proc (section 3.5.1)?
; =====
; To refresh, here's the definition of sqrt-stream Louis is trying to improve:

(define (sqrt-stream x)
    (define guesses
        (cons-stream 1.0
                     (stream-map (lambda (guess)
                                    (sqrt-improve guess x)
                                    guesses))))
    guesses)

(define (sqrt-improve guess x)
    (average guess (/ x guess)))
(define (average x y) (/ (+ x y) 2))

; What defining guesses and passing it to map does is make sure that we have one definition of the stream. Literally, it makes sure that,
; as stream-map iterates over the guesses and improves them, we use the same memory. This is what makes memo-proc work, the fact that 
; we have one stream and each delayed procedure that we force was the same delayed procedure we forced the last time at this node, 
; allowing it to return the provious results instead of calculating them anew.
;
; With Louis' suggested implementation, we don't get a single stream. Each call to sqrt-stream produces a new stream, even if x is the
; same.
;
; Finally, no, the two versions wouldn't differ in efficiency without the memo-proc optimization. That's because the definition from the
; book would be as slow as Louis', not because Louis' would be faster.
;
; (This has me wondering whether, in previous exercises, I defined a stream recursively without making sure to use the same stream each
; time. This wasn't an issue I was sensitive to before this questions. Will check... turns out I was in 3.62)