; Given an interpertation of the stream computed by the following procedure:
;
(define (expand num den radix)
    (cons-stream
        (quotient (* num radix) den)
        (expand (remainder (* num radix) den) den radix)))
;
; What are the successive elements produced by (expand 1 7 10)? What is produced by (expand 3 8 10)?
; =========
; Let's work through the examples and see what we get.
(expand 1 7 10)
(1 . (expand 3 7 10))
(1 . (4 . (expand 2 7 10)))
(1 . (4 . (2 . (expand 6 7 10))))
(1 . (4 . (2 . (8 . (expand 4 7 10)))))
(1 . (4 . (2 . (8 . (5 . (expand 5 7 10))))))
(1 . (4 . (2 . (8 . (5 . (7 . (expand 1 7 10))))))) ; and now the cycle repeats

(expand 3 8 10)
(3 . (expand 6 8 10))
(3 . (7 . (expand 4 8 10)))
(3 . (7 . (5 . (expand 0 8 10))))
(3 . (7 . (5 . (0 . (expand 8 8 10)))))
(3 . (7 . (5 . (0 . (0 . (expand 0 8 10))))) ; start cycling

; I'm not sure what these are suppose to represent. They eventually fall into cycles after some bouncing around. 
; I checked, and the numbers above are correct. If there's something beyond the cycles I'm not seeing it.

; UPDATE: I must have been tired last night. I glanced at this problem this morning and immediately recognized what we're doing.
; We're computing the decimal version of a fraction, base 10:

1 ]=> (/ 3 8.0)
;Value: .375
1 ]=> (/ 1 7.0)
;Value: .14285714285714285
1 ]=> 
