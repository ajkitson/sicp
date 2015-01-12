; In a similar way to exercise 3.71 generate a stream of all number that can be written as the sum of two squares in three different ways
; (showing how they can be so written)
; =====
; Similar to 3.71, we'll start with the stream of int pairs, sorted by the sum of their squares:
(define square-sum-pairs
    (weighted-pairs integers integers
        (lambda (p)
            (let ((a (car p)) (b (cadr p)))
                (+ (* a a) (* b b))))))


; Now we combine the adjacent pairs into triplets. On reflection, the zip procedure we used in 3.71 can be written with stream-map and
; list and, when we do that, can accomodate any number of streams:

(define (adjacent-triplets s)
    (stream-map list s (stream-cdr s) (stream-cdr (stream-cdr s))))

(define (sum-squares p)
    (+ (square (car p)) (square (cadr p))))

(define two-squares-three-ways
    (stream-map
        (lambda (triplet)  ; just tack the sum on the front
            (cons (sum-squares (car triplet)) triplet))
        (stream-filter
            (lambda (triplet)
                (= (sum-squares (car triplet))
                   (sum-squares (cadr triplet))
                   (sum-squares (caddr triplet))))
            (adjacent-triplets square-sum-pairs))))


; And here it is in action:
1 ]=> (display-n-elems 10 two-squares-three-ways)
(325 (1 18) (6 17) (10 15))
(425 (5 20) (8 19) (13 16))
(650 (5 25) (11 23) (17 19))
(725 (7 26) (10 25) (14 23))
(845 (2 29) (13 26) (19 22))
(850 (3 29) (11 27) (15 25))
(925 (5 30) (14 27) (21 22))
(1025 (1 32) (8 31) (20 25))
(1105 (4 33) (9 32) (12 31))
(1105 (9 32) (12 31) (23 24))
