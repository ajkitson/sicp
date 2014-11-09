; Using reasoning analogous to Alyssa's, describe how the difference of two intervals may be computed. Define a corresponding 
; subtraction procedure, called sub-interval.
; =====
; For addition, Alyssa figures that sum of two intervals is an interval whose upper bound is the sum of the two upper bounds and whose
; lower bound is the sum of the two lower bounds. That is, the sum interval includes all values you can get by taking a value from 
; each interval, which will be bounded on the one side by taking the smallest value from each interval and on the other side by
; taking the greatest value from each interval
;
; We can do something similar for subtraction by computing the interval that represents all possible differences of the two 
; intervals. It's upper bound will be the greatest possible difference, so the upper bound of the first interval minus the lower
; bound of the second. It's lower bound will be the least possible difference, so the lower bound of the first interval minus the
; upper bound of the second. In the case where the intervals overlap, one of the bounds will be negative, which let's say just 
; indicates there's an overlap.
;
; This reasoning is analogous to Alyssa's (subtraction computes the interval that contains all possible values of substracting and
; of one interval's values with any of the other interval's values. I'm pretty sure this is the reasoning that's supposed to be 
; analagous to Alyssa's. But there's something odd about it. Take intevals a and b. Say a + b = c. The odd thing is that c - a != b.
;
; I'll define sub-interval and then show how this works (or doesn't):
(define (sub-interval a b)
	(make-interval 
		(- (lower-bound a) (upper-bound b))
		(- (upper-bound a) (lower-bound b))))

1 ]=> (define a (make-interval 5 10))
1 ]=> (define b (make-interval 15 20))
1 ]=> (define c (add-interval a b))
1 ]=> c
;Value 5: (20 . 30)
1 ]=> (sub-interval c a)
;Value 7: (10 . 25)

; See? Here we have (5 . 10) + (15 . 20) = (20 . 30) and (20 . 30) - (5 . 10) = (10 . 25)
; And if we repeated, we could get something like a + (a - a + a - a) != a.
;
; I'm going to leave this for now. Reading ahead, it looks like we circle back to reconsider using intervals because algebra doesn't
; work predictably. Maybe this is one of the squirly things we get rid of later.
; Plus, the number represented by the interval stays the same. The uncertainty just changes with each operation.

(define (make-interval a b)
	(cons a b))
(define (upper-bound a)
	(cdr a))
(define (lower-bound a)
	(car a))
(define (add-interval a b)
	(make-interval (+ (lower-bound a) (lower-bound b))
		(+ (upper-bound a) (upper-bound b))))
