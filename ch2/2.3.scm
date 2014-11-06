; Implement a representation for rectangles in a plane. (Hint: you may want to make use of exercise 2.2.) In terms of your constructors
; and selectors, create procedures that computes the perimeter and the area of a given rectangle. Now implement a different representation
; for rectangles. Can you design your system with suitable abstraction barriers, so that the same perimeter and area procedures will
; work using either representation?
; =======
; How do we want to represent rectangles? Let's start by defining two adjoining segments. Then we'll do another that takes the 
; corners or something like that.

; Here's our first implementation:
(define (make-rect seg-a seg-b) ;seg-a and seg-b are two sides of the rect that share a corner (up to the caller to make sure...)
	(cons seg-a seg-b))

; We'll allow other procedures to interact with the rect by requesting sides a and b. You can use these to compute pretty much anything
; you want to know about the rect (including position since these are segments)
(define (rect-side-a rect)
	(car rect))
(define (rect-side-b rect)
	(cdr rect))

; A couple procedures to get our side lengths
(define (rect-side-a-length rect)
	(segment-length (rect-side-a rect)))
(define (rect-side-b-length rect)
	(segment-length (rect-side-b rect)))

; Here are our perimeter and area functions, defined in terms of rect-side-a/b-length
(define (rect-perimeter rect)
	(+ (* (rect-side-a-length rect) 2)
		(* (rect-side-b-length rect) 2)))

(define (rect-area rect)
	(* (rect-side-a-length rect)
		(rect-side-b-length rect)))

; Now, all this comes from Ex 2.2 except getting the segment length. We'll define segement length as dist between points of the segment
(define (segment-length s)
	(point-distance 
		(start-segment s)
		(end-segment s)))

; And now we compute the distance between the points:
(define (point-distance a b) ; d = sqrt((x1 - x2)^2 + (y1 - y2)^2)
	(sqrt 
		(+ (square (- (x-point a) (x-point b)))
			(square (- (y-point a) (y-point b))))))

; Let's see if this work given our first rect implementation:
; First we make a 5x10 rect with the lower left corner at (0, 0):
1 ]=> (define sideA (make-segment (make-point 0 0) (make-point 0 5)))
;Value: sidea
1 ]=> sidea
;Value 2: ((0 . 0) 0 . 5)

1 ]=> (define sideB (make-segment (make-point 0 0) (make-point 10 0)))
;Value: sideb
1 ]=> sideb
;Value 3: ((0 . 0) 10 . 0)

1 ]=> (define rect (make-rect sidea sideb))
;Value: rect

1 ]=> (rect-area rect)
;Value: 50

1 ]=> (rect-perimeter rect)
;Value: 30

; And that works! Now let's try another implementation of rect and see what we get. Let's instead represent rect intenally as
; two points representing opposite corners:
(define (make-rect a b)
	(cons a b))

; With this, we need to add a couple new selectors, so I can get the corners and then re-write the existing selectors that return 
; the sides to calculate the sides from the corners
(define (rect-corner-a rect)
	(car rect))
(define (rect-corner-b rect)
	(cdr rect))

(define (rect-side rect far-x far-y)
	(make-segment
		(rect-corner-a rect)
		(make-point (x-point far-x) (y-point far-y))))

(define (rect-side-a rect)
	(rect-side
		rect
		(rect-corner-a rect)
		(rect-corner-b rect)))

(define (rect-side-b rect)
	(rect-side
		rect
		(rect-corner-b rect)
		(rect-corner-a rect)))

; This was a bit more work but rect-area and rect-perimiter still work (using the 5x10 rect we created earlier)
1 ]=> (rect-area rect)
;Value: 50

1 ]=> (rect-perimeter rect)
;Value: 30

; Stuff from 2.2 I'm using here
(define (make-point x y)
	(cons x y))
(define (x-point p)
	(car p))
(define (y-point p)
	(cdr p))
(define (make-segment start end)
	(cons start end))
(define (start-segment s)
	(car s))
(define (end-segment s)
	(cdr s))

