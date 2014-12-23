; a. Implement the procedure pseudoremainder-terms, which is just like
; remainder-terms except that it multiplies the dividend by the
; integrerizing factor described above before calling
; div-terms. Modify gcd-terms to use pseudoremainder-terms, and verify
; that greatest-common-divisor now produces an answer with integer
; coefficients on the example in exercise 2.95
;
; b. The GCD now has integer coefficients, but they are larger than
; those of P1. Modify gcd-terms so that it removes common factors from
; the coefficients of the answer by dividing all the coefficients by
; their (integer) greatest common divisor.
; =====
; if P and Q or polys, then the integerizing factor for GCD P Q is
; the (coeff of the leading factor of Q) ^ 1 + order of Q - order of P

  (define (pseudoremainder-terms P Q)
    (let ((O1 (order (first-term P)))
          (O2 (order (first-term Q)))
          (c (coeff (first-term Q))))
      (let ((int-factor (expt c (+ 1 (- O1 O2)))))
        (remainder-terms 
          (mul-term-by-all-terms
              (make-term 0 int-factor)
              P)
          Q))))

; This does indeed get us integer coefficients:
1 ]=> (greatest-common-divisor q1 q3)
;Value 50: (polynomial x dense (2 1458) (1 -2916) (0 1458))


; Here's the new gcd-terms:
  (define (map-terms op L)
    (if (empty-termlist? L)
      '()
      (cons (op (first-term L)) (map-terms op (rest-terms L)))))

  (define (gcd-terms a b)
    (if (empty-termlist? b)
        (let ((div-by (apply gcd (map-terms coeff a))))
          (quotient-terms a (make-dense-termlist (list (make-term 0 div-by)))))
        (gcd-terms b (pseudoremainder-terms a b))))

; And here's our actual GCD:
1 ]=> (greatest-common-divisor q1 q3)
;Value 67: (polynomial x dense (2 1) (1 -2) (0 1))

; And here's how it divids into q1 and q3 respectively:
1 ]=> (define g1 (greatest-common-divisor q1 q3))
;Value: g1
1 ]=> (div q1 g1)
;Value 65: (polynomial x dense (2 11) (0 7))
1 ]=> (div q3 g1)
;Value 66: (polynomial x dense (1 13) (0 5))

