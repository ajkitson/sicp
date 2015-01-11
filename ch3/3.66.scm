; Examine the stream (pairs integers integers). Can you make any general comments about the order in which the pairs are placed into the
; steam? For example, about how many pairs precede the pair (1, 100)? the pair (99, 100)? the pair (100, 100)? (If you can make precise 
; mathematical statements here, all the better. But feel free to give more qualitative answers if you find yourself getting bogged down.)
; =====
; For context, here's pairs:
(define (pairs s t)
    (cons-stream
        (list (stream-car s) (stream-car t))
        (interleave
            (stream-map (lambda (x) (list (stream-car s) x))
                        (stream-cdr t))
            (pairs (stream-cdr s) (stream-cdr t)))))

(define (interleave s1 s2)
    (if (stream-null? s1)
        s2
        (cons-stream (stream-car s1)
                     (interleave s2 (stream-cdr s1)))))

; Interleave essentially alternates between streams. Pairs passes the first stream is our current row, and the second as all the values
; from the following rows. This means that we basically alternate (1) a value from the current row and (2) a value from one of the 
; rows further down. Because pairs calls interleave recursively (or as part of its own recursive definition), what we have is 
; basically that each new row occurs 1/2 as frequently as the previous rows, once it appears. 
;
; For example, if row 1 has 16 occurences, then we expect row 2 to have 8 occurences, and row 3 to have 4, and row 5 to have 2, and row
; 6 to have one.
;
; This isn't exact beause rows are introduced as we go. Specifically, a row is introduced only when we get to the same numbered col in 
; all the preceeding rows. So we only start row 6 once rows 1 - 5 have hit column 6. Row 1 will get there twice as fast as row 2, which 
; will get there twice as fast as row 3, etc.
;
; I'm going to take the kind authors up on their offer to not get all mathematical about this as it's late and I'm tired.
