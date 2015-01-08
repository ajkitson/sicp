; In section 2.5.3 we saw how to implement a polynomial arithmetic system representing polynomials as lists of terms. In a similar way, we
; can work with power series, such as:

; e^x = 1 + x + x^2 / 2 + x^3 / 2*3 + x^4 / 2*3*4 + ...

; cos x = 1 - x^2 / 2 + x^4 / 4*3*2 - ....

; sin x = x - x^3 / 2*3 + x^5 / 5*4*3*2 - ...
;
; represented as infinite streams. We will represent the series a0 + a1x + a2x^2 + a3x^3 as the stream whose elements are the coefficients
; a0, a1, a2, a3, ...
;
; a. The integral of the series a0 + a1x + a2x^2 + a3x^3 + ... is the series 
;
; c + a0x + 1/2(a1)x^2 + 1/3(a2)x^3 + 1/4(a3)x^4 + ...
;
; where c is any constant. Define a procedure integrate-series that takes as input a stream a0, a1, a2, ... representing a power series 
; and returns the stream a0, 1/2(a1), 1/3(a2), 1/4(a3), .... of coefficients of the non-constant terms of the integral of the series
; (Since the results have no constant term, it doesn't represent a power series; we use integrate-series, we will cons on the 
; appropriate constant.)
;
; b. The function x -> e^x is its own derivative. This implies that e^x and the integral of e^x are the same series, except for the
; constant term, whch is e^0 = 1. Accordingly, we can generate the series for e^x as 
;
; (define exp-series
;     (cons-stream 1 (integrate-series exp-series)))
;
; Show how to generate the series for sine and cosine, starting from the facts that the derivative of sine is cosine and the derivative
; of cosine is the negative of sine:
;
; (define cosine-series
;     (cons-stream 1 ??))
;
; (define sine-series
;     (cons-stream 0 ??))
;
; ==================
; This isn't as complex as it seemed to me at first. For (a) we just need to generate a stream 1 1/2 1/3 1/4... and then combine 
; that with the coefficients, which we can do with mul-stream. Then, for (b), if we defined integrate-stream correctly, we should 
; just be able to define cosine and sine in terms of each other.

; Alright, let's get started defining integrate-series. We need to get the descending fractions first. We'll combine a stream of ones
; with a stream of integers, using stream-map to combine them into numerators and denominators:

(define ones (cons-stream 1 ones))
(define (integers-starting-from n) (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))
(define fractions (stream-map (lambda (n d) (/ n d)) ones integers))

; Here we go:
1 ]=> (define fractions (stream-map (lambda (n d) (/ n d)) ones integers))
1 ]=> (stream-ref fractions 1)
;Value: 1/2
1 ]=> (stream-ref fractions 2)
;Value: 1/3
1 ]=> (stream-ref fractions 5)
;Value: 1/6

; Now we combine fractions with our coefficient stream:
(define (integrate-series coeff-stream)
    (mul-streams fractions coeff-stream))


; And this works for exp-series. (I'm not entirely clear on how the first coeff should be handled--the text mentioned there's something
; special--but the rest are correct).
1 ]=> (display-n-elems 10 exp-series)
1
1
1/2
1/6
1/24
1/120
1/720
1/5040
1/40320
1/362880

; Now for part b, where we use this to define sine and cosine via each other's integral:

(define (negate-series s)
    (stream-map (lambda (n) (* n -1)) s))

(define cosine-series
    (cons-stream 1 (negate-series (integrate-series sine-series))))

(define sine-series
    (cons-stream 0 (integrate-series cosine-series)))

; A large part of me was amazed and delighted to see this actually work:
1 ]=> (display-n-elems 10 sine-series)
0
1
0
-1/6
0
1/120
0
-1/5040
0
1/362880

1 ]=> (display-n-elems 10 cosine-series)
1
0
-1/2
0
1/24
0
-1/720
0
1/40320
0







