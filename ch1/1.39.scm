; A continued fraction representation of the tangetn function was published in 1770 by J.H. Lambert:

; tan x = 	x
; 		----------
; 		1 -		x^2
; 			------------
; 			3 - 	x^2
; 				------------
; 				5 - ...

; where x is in radians. Define a procedure (tan-cf x k) that computes an approximation to the tangent function based on labert's formula.
; K specifies the number of terms to compute.

(define (cont-frac n d k)
	(define (iter i)
		(/ (n i) 
			(+ (d i) (if (= i k) 0 (iter (+ i 1))))))
	(iter 1))

(define (tan-cf x k)
	(cont-frac 
		(lambda (i)
			(if (= i 1) x (* -1.0 x x)))
		(lambda (i)
			(- (* i 2) 1))
		k))

; To get accurate answers, you need to call tan-cf with a k around 100
1 ]=> (tan-cf 40 100)
;Value: -1.1172149309238955

1 ]=> (tan-cf 60 100)
;Value: .3200403893795631