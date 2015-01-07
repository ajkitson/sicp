; Define a procedure mul-streams, analogous to add-streams, that produces the elementwise product of its two input streams. Use this
; together with the stream of integers to complete the following definition of the stream whose nth element (counting from 0) is 
; n+1 factorial: (define factorials (cons-stream 1 (mul-streams ?? ??))).
; ======
; The mul-streams implementation is straight-forward:
(define (mul-streams s1 s2)
    (stream-map * s1 s2))

; Now for factorials, we can mulitply integers and factorials (because factorial n = n * factorial n - 1).
(define factorials (cons-stream 1 (mul-streams integers factorials)))

1 ]=> (stream-ref factorials 0)
;Value: 1
1 ]=> (stream-ref factorials 1)
;Value: 1
1 ]=> (stream-ref factorials 2)
;Value: 2
1 ]=> (stream-ref factorials 3)
;Value: 6
1 ]=> (stream-ref factorials 4)
;Value: 24
1 ]=> (stream-ref factorials 5)
;Value: 120





