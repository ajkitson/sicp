; Consider the problem of representing line segments in a plane. Each segment is represented as a pair of points: a starting point and an 
; ending point. Define a constructor make-segment and selectors start-segment and end-segment that define the representation of segments
; in terms of points. Furthermore, a point can be represented as a pair of numbers: the x coordinate and the y coordinate. Accordingly,
; specify a constructor make-point and selectors x-point and y-point that define this representation. Finally, using your selectors and
; constructors, define a procedure midpoint-segment that takes a line segment as argument and returns its midpoint (the point whose
; coordinates are the average of the endpoints). To try your procedures, you'll need a way to print points:
(define (print-point p)
	(newline)
	(display "(")
	(display (x-point p))
	(display ", ")
	(display (y-point p))
	(display ")"))

; ======
; OK, let's get started with our most basic parts, the points:
(define (make-point x y)
	(cons x y))
(define (x-point p)
	(car p))
(define (y-point p)
	(cdr p))

; Now we'll build our segments using our points:
(define (make-segment start end)
	(cons start end))
(define (start-segment s)
	(car s))
(define (end-segment s)
	(cdr s))

; I'm going to have to have a way to average these points. I'll just do an average procedure instead of getting into how to add
; and divide points
(define (add-points a b)
	(make-point 
		(+ (x-point a) (x-point b))
		(+ (y-point a) (y-point b))))

(define (divide-point p div)
	(make-point
		(/ (x-point p) div)
		(/ (y-point p) div)))

(define (average-points a b)
	(divide-point (add-points a b) 2))

; And now we'll do our midpoint procedure:
(define (midpoint-segment s)
	(average-points 
		(start-segment s) 
		(end-segment s)))

; Let's see if this works!!
1 ]=> (print-point (midpoint-segment (make-segment (make-point 10 20) (make-point 50 30))))
(30, 25)
; It does!

