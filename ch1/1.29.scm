; Simpson's rules is a more accurate method of numerical integration that then method illustrated above. Using Simpson's 
; Rule, the integral of a function f between a and b is approximated as:

; h/3 (y0 + 4y1 + 2y2 + 4y3 + 2y4 + ... + 2yn-2 + 4yn-1 + yn)

; where h = (b - a)/n, for some even integer n, and yk = f(a + kh). (Increasing n increases the accuracy of the approximation.)
; Define a procedure that takes as arguments f, a, b, and n and returns the value of the integral, computed using Simpson's Rule.
; Use your procedure to integrate cube between 0 and 1 (with n = 100 and n = 1000), and compare the results to those of the integral
; procedure shown above.
; =====
; The idea here is to practice working with an abstract summing procedure that, given a range of values will sum some transformation
; of each value in that range. E.g. sum the cubes of number 1 - 10. 
; 
; Here's the summing procedure defined in the text (from memory): 
(define (sum f a next b)
	(if (> a b)
		0
		(+ (f a) ; transform a
			(sum f (next a) next b)))) ; sum rest of range, starting with next a

; And here's the integral procedure that uses sum above:
(define (integral f a b dx)
	(define (add-dx x) (+ x dx))
	(* (sum f (+ a (/ dx 2.0)) add-dx b)
		dx))

; Now let's implement the procedure that calculate integrals using the Simpson Rule:
(define (simpson-integral f a b n)
	(define h (/ (- b a) n)) ; h = (b - a)/n, constant
	(define (inc x) (+ x 1))
	(define (get-y k)
		(* (f (+ a (* k h)))
			(cond ((or (= k 0) (= k n)) 1)
				((even? k) 2)
				(else 4))))
	(* (/ h 3.0)
		(sum get-y 0 inc n)))

; And it works, even with small value for n (for cube between 0 and 1 at least): 
1 ]=> (simpson-integral cube 0 1 100)
;Value: .25

1 ]=> (simpson-integral cube 0 1 1000)
;Value: .25

1 ]=> (simpson-integral cube 0 1 10)
;Value: .25

1 ]=> (simpson-integral cube 0 1 2)
;Value: .25
