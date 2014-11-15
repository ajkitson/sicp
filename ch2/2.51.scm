; Define the below operation for painters. below takes two painters as arguments. The resulting painter, given a frame, draws with the
; first painter in the bottom of the frame and with the second painter in the top. Define below in two different ways--first by
; writing a procedure that is analogous to the beside procedure given above, and again in terms of beside and suitable rotation
; operations (from exercise 2.50).
; =====
;
; Here it is in the style of beside 
(define (below p-bottom p-top)
	(let ((split-point (make-vect 0 0.5)))
		(let ((paint-top 
				((transform-painter
					split-point
					(make-vect 1 0.5)
					(make-vect 0 1))
				p-top))
			(paint-bottom
				((transform-painter
					(make-vect 0 0)
					(make-vect 1 0)
					split-point) 
				p-bottom)))
			(lambda (frame)
				(paint-top frame)
				(paint-bottom frame)))))
				
; and now with beside and rotation operations:
(define (below p-bottom p-top)
	(rotate270 (beside (rotate90 p-top) (rotate90 p-bottom))))