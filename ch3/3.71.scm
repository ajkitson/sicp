; Numbers that can be expressed as the sum of two cubes in more than one way are sometimes called Ramanujan numbers, in honor of the 
; mathematician Srinivasa Ramanujan. Ordered streams of pairs provide an elegant solution to the problem of computing these numbers. To find
; a number that can be written as the sum of two cubes in two different ways, we need only generate the stream of pairs of integers
; (i, j) weighted according to the sum i^3 + j^3, then search the streams for two consecutive pairs with the same weight. Write a procedure
; to generate the Ramanujan numbers. The first such number is 1,729. What are the next five?
; =========
; Ooo! This'll be fun.
; First we generate the ordered stream of pairs:
(define cube-sum-pairs
    (weighted-pairs integers integers
        (lambda (p) 
            (let ((a (car p)) 
                  (b (cadr p)))
                (+ (* a a a) 
                   (* b b b))))))

; Then we need a way to select adjacent pairs that are the same. Or rather, before we can select adjacent pairs, we need to compare 
; adjacent pairs. We already have a stream-filter that processes a single stream. Let's create a general zip that'll combine two 
; streams. We'll run cub-sum-pairs and it's cdr through this, which will give us a stream whose elements are the adjacent pairs
; of the input streams. Then we'll filter that on whether the zipped elements' cubes add up to the same thing.

(define (zip s1 s2)
    (cons-stream
        (list (stream-car s1) (stream-car s2))
        (zip (stream-cdr s1) (stream-cdr s2))))

(define ramanujan-numbers
    (stream-map
        (lambda (pairs)
            (let ((a (car (car pairs)))
                  (b (cadr (car pairs))))
                (+ (* a a a) (* b b b))))
        (stream-filter
            (lambda (pairs) 
                (let ((a (car (car pairs)))
                      (b (cadr (car pairs)))
                      (c (car (cadr pairs)))
                      (d (cadr (cadr pairs))))
                    (= (+ (* a a a) (* b b b))
                       (+ (* c c c) (* d d d)))))
            (zip cube-sum-pairs 
                 (stream-cdr cube-sum-pairs)))))

; And it works!!
1 ]=> (display-n-elems 10 ramanujan-numbers)

1729
4104
13832
20683
32832
39312
40033
46683
64232
65728



