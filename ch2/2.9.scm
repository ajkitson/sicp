; The width of an interval is half the difference between its upper and lower bounds. The width is a measure of the uncertainty of the 
; number specified by the interval. For some arithmetic operations the width of the result of combining two intervals is a function
; only of the widths of the argument intervals, whereas for others the width of the combination is not a function of the widths of the
; argument intervals. Show that the width of the sum (or difference) or two intervals is a function only of the widths of the intervals
; being added (or subtracted). Give examples to show that this is not true of multiplication or division.
; ======

; Recall that we add two intervals by creating a new interval whose lower bound is the sum of the lower bounds of the argument 
; intervals and whose upper bound is the sum of the upper bounds of the argument intervals.

; Say we have these intervals:
; (a . b) and (c . d)
; The width of the first interval is (b - a)/2 and the width of the second is (d - c)/2.
; If we add these intervals, we get a new interval: ((a + c) . (b + d)), whose width is ((b + d) - (a + c))/2.
; Now, we can reduce this width to a function of the widths of it's constituent intervals:
((b + d) - (a + c))/2
(b + d - a - c)/2
(b - a + d - c)/2
(b - a)/2 + (d - c)/2
; And we've arrived back at our original widths, added together.

; Now for examples of multiplication and division that show that result interval's width isn't just a fn of the argument intrevals
; Here we have widths of 5 for each interval and a width of 250 for their product.
1 ]=> (define a (make-interval 10 20))
1 ]=> (define b (make-interval 30 40))
1 ]=> (mul-interval a b)
;Value 8: (300 . 800)

; Here we have intervals that also have a width of 5 but whose product has a width of 555. So the product witdth can't be a function
; of just the width of the argument intervals. Otherwise the product would have the same width if the arguments had the same width.
1 ]=> (define a (make-interval 1 11))
1 ]=> (define b (make-interval 100 110))
1 ]=> (mul-interval a b)
;Value 9: (100 . 1210)

; Same thing holds with division:

1 ]=> (define a (make-interval 10 20))   ; width of 5
1 ]=> (define b (make-interval 100 200)) ; width = 50
1 ]=> (div-interval b a)
;Value 10: (5 . 20)						; width = 7.5

1 ]=> (define a (make-interval 50 60)) ; width = 5
1 ]=> (define b (make-interval 500 600)) ; width = 50
1 ]=> (div-interval b a)				; width = 1.83333333
;Value 11: (25/3 . 12)





(define (mul-interval a b)
	(let ((p1 (* (lower-bound a) (lower-bound b)))
			(p2 (* (lower-bound a) (upper-bound b)))
			(p3 (* (upper-bound a) (lower-bound b)))
			(p4 (* (upper-bound a) (upper-bound b))))
	(make-interval (min p1 p2 p3 p4) (max p1 p2 p3 p4))))

(define (div-interval a b)
	(mul-interval a (make-interval (/ 1 (upper-bound b)) (/ 1 (lower-bound b)))))
