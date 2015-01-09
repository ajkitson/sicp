; Use the series ln2 = 1 - 1/2 + 1/3 - 1/4 .... to compute three sequences of approximations to the natural logarithm of 2, in the 
; same way we did above for pi. How repidly do these sequences converge?
; =======
; Alrighty! I was getting worried we wouldn't be able to play around with these transformations... the tableau is particularly stunning
; and hard to think about. 
;
; First we'll define our ln2-stream. Here's the style used in the book. The stream-map part doesn't feel natural to me, but it works.
(define (ln2-summands n)
    (cons-stream (/ 1 n)
                 (stream-map - (ln2-summands (+ n 1)))))  ; map - to alternate pos and neg elems

; This feels a little more natural to me:
(define pos-neg
    (cons-stream 1.0 (scale-stream pos-neg -1)))

(define ln2-summands
    (mul-streams pos-neg (stream-map / ones integers)))

; Then we use partial-sums to get improving estimates os ln2
(define ln2-stream (partial-sums ln2-summands))

(define (partial-sums s)
    (cons-stream (stream-car s)
                 (add-streams (stream-cdr s) 
                              (partial-sums s))))

; That gives us the these 10 estimates:
1 ]=> (display-n-elems 10 ln2-stream)

1.
.5
.8333333333333333
.5833333333333333
.7833333333333332
.6166666666666666
.7595238095238095
.6345238095238095
.7456349206349207
.6456349206349207


; Now let's use Euler's transform to converge a bit quicker. Here's the transform:
(define (euler-transform s)
    (let ((s0 (stream-ref s 0))
          (s1 (stream-ref s 1))
          (s2 (stream-ref s 2)))
        (cons-stream (- s2 (/ (square (- s2 s1))
                              (+ s0 (* -2 s1) s2)))
                     (euler-transform (stream-cdr s)))))

; Now when we wrap our ln2-stream in the transform we converge more quickly:
1 ]=> (display-n-elems 10 (euler-transform ln2-stream))

.7
.6904761904761905
.6944444444444444
.6924242424242424
.6935897435897436
.6928571428571428
.6933473389355742
.6930033416875522
.6932539682539683
.6930657506744464

; Now we make a tableau! This is like partial-sums in that each element is a stream taht is a transformation of the previous one:
(define (make-tableau transform s)
    (cons-stream s 
                 (make-tableau transform (transform s))))

; This gives us a stream of streams. But we need estimates! So we pull the first off of each of the streams:
(define (accelerated-sequence transform s)
    (stream-map stream-car (make-tableau transform s)))

; And now we home in super fast!!
1 ]=> (display-n-elems 10 (accelerated-sequence euler-transform ln2-stream))

1.
.7
.6932773109243697
.6931488693329254
.6931471960735491
.6931471806635636
.6931471805604039
.6931471805599445
.6931471805599427
.6931471805599454



