; Use the results of exercises 3.60 and 3.61 to define a procedure div-series that divides two power series. div-series should work for 
; any two series, provider that the denominator begines with a non-zero constant term (if the denominator as a zero constant term, then 
; div-series should signal an error). Show how to use div-series together with the result of exercises 3.59 to generate the power
; series for tangent.
; ====
; We just define div-series as the numerator series multiplied by the inverse of the denominator series, with an error check on the 
; constant term of the denominator

(define (div-series n-ser d-ser)
    (if (= (stream-car d-ser) 0)
        (error "Cannot divide by stream with zero as constant term" (list n-ser d-ser))
        (mul-series n-ser (invert-unit-series d-ser))))
    
; Then we just define tangent like so:
(define tangent-series
    (div-series sine-series cosine-series))

; And these coefficients match up with the expansion from wolfram.com (http://mathworld.wolfram.com/SeriesExpansion.html):
1 ]=> (display-n-elems 10 tangent-series)

0
1
0
1/3
0
2/15
0
17/315
0
62/2835

