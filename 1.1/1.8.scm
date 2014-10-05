; Newton's method for cube roots is based on the fact that if y is an aproximation of the cube root of x, then a better
; approximation is given by the value  (x/y^2 + 2y) / 3. Use this formula to implement a cube-root procedure anologous
; to the sqrt procedure. 

; Let's see if we can do this without looking it up...
(define (cube-root x)
	(define (cube-root-iter guess old-guess x)
		(if (good-enough? guess old-guess)
			guess
			(cube-root-iter (improve guess x) 
							guess 
							x)))
	(define (good-enough? guess old-guess)
		(define threshold .00001)
		(< (/ (abs (- guess old-guess)) 
				old-guess)
			threshold))
	(define (improve guess x)
		(/ (+ (/ x (* guess guess)) 
				(* 2 guess))
			3))

	(cube-root-iter 1.0 10.0 x))

; This works pretty well;
1 ]=> (cube-root 27)
;Value: 3.0000000000000977

1 ]=> (define (cube x) (* x x x))
;Value: cube

1 ]=> (cube-root (cube 50))
;Value: 50.

1 ]=> (cube-root (cube 4))
;Value: 4.000000000076121

1 ]=> 
