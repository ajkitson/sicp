; Modify the pairs procedure so that (pairs integers integers) will produce the stream of all pairs of integers (i, j) (without the condition
; i <= j). Hint: you will need to miz in an additional stream.
; ========
; The original pairs combined a stream that marched across rows with the stream that calculated all the other pairs. To do all integers,
; will just interleave a stream that marches down columns. We'll interleave it with the stream that marches across rows. The resultant
; stream will be interleaved with the remainging pairs.

(define (pairs s t)
    (cons-stream
        (list (stream-car s) (stream-car t))
        (interleave
            (interleave
                (stream-map (lambda (x) (list (stream-car s) x))
                            (stream-cdr t))
                (stream-map (lambda (x) (list x (stream-car t)))
                            (stream-cdr s)))
            (pairs (stream-cdr s) (stream-cdr t)))))


; Here we go:
1 ]=> (define all (pairs integers integers))
1 ]=> (display-n-elems 20 all)

(1 1)
(1 2)
(2 2)
(2 1)
(2 3)
(1 3)
(3 3)
(3 1)
(3 2)
(1 4)
(3 4)
(4 1)
(2 4)
(1 5)
(4 4)
(5 1)
(4 2)
(1 6)
(4 3)
(6 1)
