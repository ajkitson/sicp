; Write a procedure triples that takes three infinite streams, S, T, and U, and produces the stream of triples (Si, Tj, Uk) such that 
; i <= j <= k. use tiples to generate the stream of all Pythagorean triples of positive integers, i.e. the triples (i, j, k) such that
; i <= j and i^2 + j^2 = k^2.
; ======
; A triple is just a pair plus another element, so we can use some of what we did with pairs. But it's not as easy as I'd hoped.
;
; The highlevel explanation is simple. We just use our pairs procedure to generate all the pairs for streams j and k. Then we 
; map i across our pairs stream, giving us triples. 
;
; But the devil is in the details. Specifically, what do we pass to our pairs stream? If we pass the cdr of j and k, then we omit
; triples where i = j and both are less than k. OK, so you think we can pass j and the cdr of k. But then we never get the 
; pair where j = k. Then you think, what if we just create pairs using j and k. Well, that gets you the pairs you need and it you
; map i over them, you have all triples. But that's too many, because you're already creating the triple where i = j = k. However,
; you can't just omit the cons-stream part, as we learned in exercise 3.68 (fortunately--that would have been a rabbit hole.)
;
; So the answer is to have two nested cons-streams, one to create the triple where i = j = k, and the other to create the triple
; where i = j < k. Then the rest are created with interleave.

(define (triples i j k)
    (cons-stream
        (list (stream-car i) (stream-car j) (stream-car k))
        (cons-stream
            (list (stream-car i) (stream-car j) (stream-car (stream-cdr k)))
            (interleave 
                (stream-map (lambda (pair) (cons (stream-car i) pair))
                                (pairs (stream-cdr j) (stream-cdr k)))
                (triples (stream-cdr i) (stream-cdr j) (stream-cdr k))))))

; From there, we can just use stream-filter to find pythagorean triples:
(define pythagorean-stream
    (stream-filter
        (lambda (t) (= (+ (square (car t))
                          (square (cadr t)))
                       (square (caddr t))))
        (triples integers integers integers)))

; And here are the first few:
4 ]=> (display-n-elems 5 pythagorean-stream)

(3 4 5)
(6 8 10)
(5 12 13)
(9 12 15)
(8 15 17)
