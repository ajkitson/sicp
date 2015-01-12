; It would be nice to be able to generate stream in which the pairs appear in some useful order, rather than in the order that results from
; an ad hoc interleaving process. We can use a techniques similar to the merge procedure of exercise 3.56, if we define a way to say that
; one pair of integers is less than another. One way to do this is to define a "weighting function" W(i, j) and stipulate that (i1, j1)
; is less than (i2, j2) if W(i1, j1) < W(i2, j2). Write a procedure merge-weighted that is like merge, except that merge-weighted takes
; an additional argument weight, which is a procedure that computes the weight of a pair, and is used to determine the order in which the 
; elements should appear in the resulting merged stream. Using this, generalize pairs to a procedure weighted-pairs that takes two streams,
; together with a procedure that computes a weighting function, and generates the stream of pairs, ordered according to weight. User your
; procedure to generate:

; a. the steam of all pairs of positive integers (i, j) with i <= j, ordered according to the sum i + j.

; b. the stream of all pairs of positive integers (i, j) with i <= j, where neither i nor j is divisible by 2, 3, or 5, and the pairs 
; are ordered accourding to the sum 2i + 3j + 5ij.
; =========
; Alright, let's get started with merge-weighted. I'll write merge-weighted to pass weight single argument. That way we can use it for 
; any stream, not just pairs (it'll be up to the weighting function to piece out the list).
;
; One thing that's unclear is what to do when the weight is the same. With merge, we ignored duplicates. Here, however, duplicate 
; weights doesn't mean duplicate values. For example, in (a) above, the pairs 1 3 and 2 2 will have the same weight. We don't have a 
; mechanism to choose one over the other and we don't want to exclude one arbitrarily. What to do? We'll just be consistent and use the
; first stream if it's a tie. If distinguishing between these cases is important, the weight procedure should give them unique weights

(define (merge-weighted s1 s2 weight)
    (cond ((stream-null? s1) s2)
          ((stream-null? s2) s1)
          (else (let ((w1 (weight (stream-car s1)))
                      (w2 (weight (stream-car s2))))
                  (if (<= w1 w2)  
                      (cons-stream (stream-car s1)  ; in case w1 == w2, just go with s1
                                   (merge-weighted s2 (stream-cdr s1) weight))
                      (cons-stream (stream-car s2)
                                   (merge-weighted s1 (stream-cdr s2) weight)))))))

; Now we generalize the pairs procedure:
(define (weighted-pairs s t weight)
    (cons-stream
        (list (stream-car s) (stream-car t))
        (merge-weighted
            (stream-map (lambda (x) (list (stream-car s) x))
                        (stream-cdr t))            
            (weighted-pairs (stream-cdr s) (stream-cdr t) weight)
            weight)))

; And now we can do a and b.
(define ordered-pairs
    (weighted-pairs integers integers 
                    (lambda (p) (+ (car p) (cadr p)))))

; It works!
1 ]=> (display-n-elems 30 ordered-pairs)

(1 1)
(1 2)
(2 2)
(1 3)
(2 3)
(1 4)
(3 3)
(1 5)
(2 4)
(1 6)
(3 4)
(2 5)
(1 7)
(4 4)
(2 6)
(3 5)
(1 8)
(2 7)
(4 5)
(3 6)
(1 9)
(2 8)
(5 5)
(3 7)
(4 6)
(1 10)
(2 9)
(3 8)
(5 6)
(4 7)
;
; and b:
(define (divisible-by-any n divs)
    (cond ((null? divs) false)
          ((= (remainder n (car divs)) 0) true)
          (else (divisible-by-any n (cdr divs)))))
(define integers-235
    (stream-filter
        (lambda (p) (and (not (divisible-by-any (car p) (list 2 3 5)))
                         (not (divisible-by-any (cadr p) (list 2 3 5)))))
        (weighted-pairs integers integers
                        (lambda (p) (+ (* 2 (car p)) 
                                       (* 3 (cadr p)) 
                                       (* 5 (car p) 
                                            (cadr p)))))))



1 ]=> (display-n-elems 20 integers-235)

(1 1)
(1 7)
(1 11)
(1 13)
(1 17)
(1 19)
(1 23)
(1 29)
(1 31)
(7 7)
(1 37)
(1 41)
(1 43)
(1 47)
(1 49)
(1 53)
(7 11)
(1 59)
(1 61)
(7 13)
