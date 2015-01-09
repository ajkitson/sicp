; Write a procedure stream-limit that takes as arguments a stream and a number (the tolerance). It should examine the tream until it finds
; two successive elemnts that differ in absolute value by less than the tolerance, and return the second of the two elements. Using this,
; we could compute square roots up to a given tolerance by
;
; (define (sqrt x tolerance)
;     (stream-limit (sqrt-stream x) tolerance))
; ======
; No creating streams in this one--just traversing--so pretty straightforward

(define (stream-limit stream tolerance)
    (if (stream-null? stream)
        (error "No values within tolerance" (list stream diff))
        (let ((a (stream-car stream))
              (b (stream-car (stream-cdr stream))))
            (if (< (abs (- a b)) 
                    tolerance)
                b
                (stream-limit (stream-cdr stream) tolerance)))))


1 ]=> (sqrt 16 0.1)
;Value: 4.000000636692939
1 ]=> (sqrt 16 .00001)
;Value: 4.000000000000051
1 ]=> (sqrt 16 0.0000000000000001)
;Value: 4.

