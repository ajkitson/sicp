; Define P1, P2, and P3 to be polynomials
; P1: x^2 - 2x + 1
; P2: 11x^2 + 7
; P3: 13x + 5

; Now define Q1 to be the product of P1 and P2 and Q2 to be the product
; of P1 and P3, and use the greatest-common-divisor to compute the gcd
; of Q1 and Q2. Note that the answer is not the same as P1. This example
; introduces noninteger operations into the computation, causing
; difficulties with the GCD algorithm. To understand what is happening,
; try tracing gcd-terms while computing the GCD or try performing the
; division by hand
; =====
; OK, I guess we're just supposed to see this fail and then understand why it does.
; Feel like I've worked through this a thousand times already in debugging arithmetic.scm
;
; ... but it actually works, though the coefficients aren't integers:

1 ]=> (greatest-common-divisor q1 q2) 
;Value 16: (polynomial x dense (2 1458/169) (1 -2916/169) (0 1458/169))  

; Here I've modified gcd to print out a and b as we go:
(gcd-terms (dense (4 11) (3 -22) (2 18) (1 -14) (0 7)) (dense (3 13) (2 -21) (1 3) (0 5)))
(gcd-terms (dense (3 13) (2 -21) (1 3) (0 5)) (dense (2 1458/169) (1 -2916/169) (0 1458/169)))
(gcd-terms (dense (2 1458/169) (1 -2916/169) (0 1458/169)) (dense))
;Value 18: (polynomial x dense (2 1458/169) (1 -2916/169) (0 1458/169))

; As the footnote says, we get rational number coefficients in mit-scheme


