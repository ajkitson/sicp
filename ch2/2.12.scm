; Define a constructor make-center-percent that takes a center and percentage tolerance and produces the desired interval. You must also 
; define a selector percent that produces the percentage tolerance for a given interval. The center selector is the same as the one above.

(define (make-center-percent c p)
	(define (width-from-percent c p)
		(* c (/ p 100.0)))
	(make-center-width c (width-from-percent c p)))

(define (percent i)
	(* (/ (width i) (center i)) 100.0))

; the below were defined earlier, pg 95
(define (make-center-width c w)
	(make-interval (- c w) (+ c w)))

(define (center i)
	(/ (+ (lower-bound i) (upper-bound i)) 2))

(define (width i)
	(/ (- (upper-bound i) (lower-bound i)) 2))

; and they work:
1 ]=> (make-center-percent 10 50)
;Value 3: (5 . 15)

1 ]=> (percent (make-center-percent 10 50))
;Value: 50
