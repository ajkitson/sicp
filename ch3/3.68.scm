; Louis Reasoner thinks that building a stream of pairs from three parts is unnecessarily complicated. Instead of separating the pair 
; (S0, T0) from the rest of the pairs in the first row, he proposes to work with the whole first row as follows:

(define (pairs s t)
    (interleave
        (stream-map 
            (lambda (x) (list (stream-car s) x))
            t)
        (pairs (stream-cdr s) (stream-cdr t))))

; Does this work? Consider what happens if we evaluate (pairs integers integers) using Louis' definition of pairs.
; =======
; I tried to reason this out and wasn't getting it, so I just tried it. 
;
; Here's the issue:
1 ]=> (define l (pairs integers integers))
;Aborting!: maximum recursion depth exceeded

; Why is this happening? The issues is using pairs as an second argument to interleave. When we evaluate (pairs integers integers), we
; run interleave and must evaluate (pairs (stream-cdr s) ...) as its a parameter to interleave. But that just puts us back where we 
; were, having to evaluate interleave and the result of (pairs...). So we keep looping and looping and don't stop.
;
; Why doesn't this happen in the definition if pairs that uses cons-stream? Because cons-stream delays the evaluation of interleave.
; The other definition is therefore able to return a value without having to evaluate pairs.




