; With the power series represented as streams of coefficients as in exercise 3.59, adding series is implemented by add-streams. Complete
; the definition of the following procedure for multiplying series:

; (define (mul-series s1 s2)
;     (cons-stream ?? (add-streams ?? ??)))

; You can test your procedure by verifying that sin^2x + cos^2x = 1.
; =====
; We can treat multiplying two power series like multiplying two polynomials -- these polynomials just happen to be infinitely long,
; which is why streams are a good choice .
;
; To do this multiplication, we simply multiply each term in one by each term in the other and take the sum of all the multiplied 
; terms.
; 
; The first coefficient of our product stream is therefore the first two coefficients of the input stream multiplied together.
; The remaining coefficients are the sum of (1) the first coefficient in the first input stream multiplied by all the coefficients 
; in the other, and (2) the remaining coefficients in the first input stream multiplied the second input stream

(define (mul-series s1 s2)
    (cons-stream 
        (* (stream-car s1) (stream-car s2))   ; first elem
        (add-streams 
            (scale-stream (stream-cdr s2) (stream-car s1))
            (mul-series (stream-cdr s1) s2))))

; Here it works:
(define test 
    (add-streams
        (mul-series sine-series sine-series)
        (mul-series cosine-series cosine-series)))

1 ]=> (display-n-elems 10 test)

1
0
0
0
0
0
0
0
0
0

; This test doesn't seem quite right, though. We're computing coefficients on x, right? So although this is just a big sum, the order
; of terms matters because it determines which power of x it's a coefficient of. And really, we don't have a way to indicate which 
; elements fall together as a single coefficient. Because our test is just a 1 and a bunch of 0s, we don't know whether we got it right.
; For all we know, the zeros could be out of order. Right?

; But let's do another, just for fun. It won't address the previous concerns about order and grouping of coefficients, but will 
; show we're at least generating the right terms. If x = 1, then (sinx)^2 is just the sum of the coefficients. We can see that
; mul-streams calculates this correctly, and more accurately the more terms we look at:

1 ]=> (define s2 (mul-series sine-series sine-series))
1 ]=> (sum-stream 10 s2)
;Value: .707936507936508
1 ]=> (sum-stream 100 s2)
;Value: .7080734182735714

1 ]=> (* (sin 1) (sin 1))
;Value: .7080734182735712



; Some code to help get the series when x = 1
(define (accumulate-stream proc total n s)
    (if (> n 0)
        (accumulate-stream proc (proc total (stream-car s)) (- n 1) (stream-cdr s))
        total))

(define (sum-stream n s)
    (accumulate-stream + 0.0 n s))
