; Define the transformation flip-horiz, which flips painters horizontally, and transformations that rotate painters counter-clockwise
; by 180 degrees and 270 degrees.
; =====
; flip-horiz is similar to flip-vert:
(define (flip-horiz painter)
	((transform-painter   ; NOTE: in the book, transform-painter takes painter as the first argument, but in the library it returns a lambda that takes a painter
		(make-vect 1 0)
		(make-vect 0 0)
		(make-vect 1 1))
	painter))

; I'm going to define the rotation procedures in terms of rotate90 defined in the book. It's probably not as fast as defining them
; directly, but it's more fun.
(define (rotate90 painter)
	((transform-painter
		(make-vect 1 0)
		(make-vect 1 1)
		(make-vect 0 1))
	painter))

(define (rotate180 painter)
	(rotate90 (rotate90 painter)))
(define (rotate270 painter)
	(rotate90 (rotate180 painter)))
