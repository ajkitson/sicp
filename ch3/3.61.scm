; Let S be a power series (exercise 3.59) whose constant term is 1. Suppose we want to find the power series 1/S, that is, the series X
; such that S * X = 1. Write S = 1 + Sr where Sr is the part of S after the constant term. Then we can solve for X as follows:

; S * X = 1
; (1 + Sr) * X = 1
; X + Sr * X = 1
; X = 1 - Sr * X

; In other words, X is the power series whose constant term is 1 and whose higher-order terms are given by the negative of Sr times X. Use
; this idea to write a procedure invert-unit-series that computes 1/S for a power series S with constant term 1. You will need to use
; mul-series from 3.60.
; =======
; We can do this just cobbling things together. We need the first element to be 1 since X = 1 - Sr * X. From there, we multiply
; X and Sr and scale it by -1. X is just (invert-unit-series S), and Sr is just the cdr of S. Then we use scale-stream to multiply 
; by -1.
;
; Actually, correction: we need the first element to be the constant term. 1 was used in the example above, but any constant will do.

; (define (invert-unit-series s)
;     (cons-stream 
;         (stream-car s) ; constant term
;         (scale-stream 
;             (mul-series (invert-unit-series s) (stream-cdr s))
;             -1)))

; Updated to create a 
(define (invert-unit-series s)
    (define invert
        (cons-stream 
            (stream-car s) ; constant term
            (scale-stream 
                (mul-series invert (stream-cdr s))
                -1)))
    invert)


1 ]=> (define test (mul-series cosine-series (invert-unit-series cosine-series)))
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

1 ]=> (define test (mul-series exp-series (invert-unit-series exp-series)))
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
