; Monte Carlo integration is a method of estimating definite integrals by means of Monte Carlo simulation. Consider computing the area
; of a region of space described be a predicate P(x, y) that is true for points (x, y) in the region and false for points not in the
; region. For example, the region contained within a circle of radius 3 centered at (5, 7)is described by the predicate that tests
; whether (x-5)^2 + (y-7)^2 <= 3^2. To estimate the area of the rgion described by such a predicate, begin by choosing a rectangle that
; contains the region. For example, a rectangle with diagonally opposite corders at (2, 4) and (8, 10) contains the circle above. The 
; desired integral is the area of that portion of the rectanlge that lies in the region. We can estimate the integral by picking, at
; random, points that lie in the rectangle and testing P(x, y) for each point to determine whether the point lies in the region. If we 
; try this with many points, then the fraction of points that fall in the region should give an estimate of the proportion of the
; rectangle that lies in the region. Hence, multiplying this fraction by the area of the entire rectangle should produce an estimate 
; of the integral. 

; Implement Monte Carlo integration as a procedure estimate-integral that takes as arguments a predicate P, upper and lower bounds
; x1, x2, y1, y2 for the rectangle, and the number of trials to perform in order to produce the estimate. Your procedure should
; use the same monte-carlo procedure that was used above to estimate pi.

; You will find it useful to have a procedure that returns a number chosen at random from a given range. The following random-in-range
; procedure implements this in terms of the random procedure used in section 1.2.6, which returns a nonnegative number less than its 
; input.
;
; (define (random-in-range low high)
; 	(let ((range (- high low)))
; 		(+ low (random range))))
;
; ======
; We'll need a few things to get this working: the monte carlo procedure from the text, a procedure to pass to monte-carlo to test 
; a random x and random y against our predicate, a wrapper for all of this that will calculate the area of the rect and get the area
; of the region using the results of the monte-carlo simulation, and a predicate we can use to test.
;
; Here's monte-carlo from the text:
(define (monte-carlo trials experiment)
	(define (iter trials-remaining trials-passed)
		(cond 
			((= 0 trials-remaining)
				(/ trials-passed trials))
			((experiment)
				(iter (- trials-remaining 1) (+ trials-passed 1)))
			(else 
				(iter (- trials-remaining 1) trials-passed))))
	(iter trials 0))

; Now we'll write the procedure we'll pass to monto carlo (bounds-test) and we'll wrap it in the overall procedure to get 
; the integral:
(define (estimate-integral P x1 x2 y1 y2 trials)
	(define (float i) (* i 1.0))
	(define (bounds-test)
		(P (random-in-range (float x1) (float x2)) 
		   (random-in-range (float y1) (float y2))))
	(let ((rect-area (* (- x2 x1) (- y2 y1)))
		  (region-percent (monte-carlo trials bounds-test)))
		(* 1.0 (* rect-area region-percent))))

; we'll use this procedure to give us a predicate to test. It tests whether a point is in a circle.
(define (make-circle-predicate radius cx cy)
	(let ((hypotenuse (square radius)))
		(lambda (x y)
			(<= (+ (square (- x cx))
				  (square (- y cy)))
				hypotenuse))))

; And here it is all together:
1 ]=> (define circle-1 (make-circle-predicate 1 1 1))
1 ]=> (estimate-integral circle-1 0 2 0 2 1000)
;Value: 3.12
1 ]=> (estimate-integral circle-1 0 2 0 2 1000)
;Value: 3.144
1 ]=> (estimate-integral circle-1 0 2 0 2 1000)
;Value: 3.156



