; Use segments->painter to define the following primitive painters:
; a. the painter that draws the outline of the designated frame
; b. the painter that draws an "X" by connecting opposite corners of the frame
; c. the painter that draws a diamond shape by connecting the midpoints of the sides of the frame
; d. the wave painter
; =====
; Good, this will tie things together nicely--the last few exercises felt too piecemeal.
;
; First, let's get segments->painter and its supporting procedures defined:
;
; Return procedure that will run through segments and draw each in a given frame
(define (segments->painter segment-list)
	(lambda (frame)
		(display frame)
		(for-each
			(lambda (segment)
				(draw-line  
					((frame-coord-map frame) (start-segment segment)) ; why don't we just define (frame-coord-map frame) once? frame-coord-frame just returns a lambda so it's like calling it twice on each for-each pass is so bad, but still... maybe something I don't get?
					((frame-coord-map frame) (end-segment segment))))
			segment-list)))

; return function to translate vectors from 0-1 square frame to coords in new frame
(define (frame-coord-map frame) 
	(lambda (v)
		(add-vect
			(origin frame) ; move to new origin
			(add-vect 
				(scale-vect (xcor-vect v) (edge1 frame))
				(scale-vect (ycor-vect v) (edge2 frame))))))

; Alrighty, now that we've got those in place (and got a bit of a refresher), let's start drawing. I'll be using DrRacket for these
; since mit-scheme is stubborn about compiling the picture lang libraries. 
;
; a. painter that draws the outline of the designated frame. 
(define frame-painter
	(let ((one .99)) ; for far borders, if you draw along 1, it doesn't show up (at least in DrRacket), need to do .99
		(let ((ll (make-vect 0 0)) 
				(ul (make-vect 0 one))
				(ur (make-vect one one))
				(lr (make-vect one 0)))
			(segments->painter  ; trace border clockwise
				(list (make-segment ll ul) (make-segment ul ur) (make-segment ur lr) (make-segment lr ll))))))


; b painter that dras an "X" by connecting opposite corners
(define x-painter
	(segments->painter 
		(list (make-segment (make-vect 0 0) (make-vect 1 1)) 
			(make-segment (make-vect 1 0) (make-vect 0 1)))))

; c painter that draws a diamond bu connecting the midpoints
(define diamond-painter
	(let ((left (make-vect 0 0.5))
			(right (make-vect 1 0.5))
			(top (make-vect 0.5 1))
			(bottom (make-vect 0.5 0)))
		(segments->painter 
			(list (make-segment left top) 
				(make-segment top right) 
				(make-segment right bottom) 
				(make-segment bottom left)))))

; d. the wave painter. Is there some breakdown to this? If the wave painter decomposes to simpler forms, I can't see it... :(
;
; This threatened to be tedious, defining a bunch of segments, so I created a procedure that will take a list of vectors
; and convert it to a set of connecting segments. We basically zip a list of start points and end points together with 
; make-segment. These two lists are the same execpt the first and last item.
(define (vectors-to-connecting-segments vectors)
	(define (get-rid-of-last things) ; return list - last item
		(reverse (cdr (reverse things))))
	(map make-segment (get-rid-of-last vectors) (cdr vectors)))

; This is still long and tedious but less than it would have been otherwise. The points aren't exact, but the general shape
; is correct
(define wave-painter 
	(segments->painter 
		(append 
			(vectors-to-connecting-segments ;between legs
				(list (make-vect 0.4 0) 
					(make-vect 0.5 0.3) 
					(make-vect 0.6 0)))
			(vectors-to-connecting-segments ; lower right side
             	(list (make-vect 0.25 0) 
             		(make-vect 0.35 0.5)
             		(make-vect 0.25 0.6)
             		(make-vect 0.15 0.4)
             		(make-vect 0 0.7)))
             (vectors-to-connecting-segments ; upper right side
	         	(list (make-vect 0 0.9)
	         		(make-vect 0.15 0.6)
	         		(make-vect 0.25 0.7)
	         		(make-vect 0.4 0.7)
	         		(make-vect 0.35 0.85)
	         		(make-vect 0.4 1)))
             (vectors-to-connecting-segments
             	(list (make-vect 0.6 1)
             		(make-vect 0.65 0.85)
             		(make-vect 0.6 0.7)
             		(make-vect 0.7 0.7)
             		(make-vect 1 0.4)))
             (vectors-to-connecting-segments
             	(list (make-vect 1 0.2)
             		(make-vect 0.6 0.5)
             		(make-vect 0.7 0))))))

; Can also re-write diamond and frame using vectors-to-connecting-segments:
(define diamond-painter
	(let ((left (make-vect 0 0.5))
			(right (make-vect 1 0.5))
			(top (make-vect 0.5 1))
			(bottom (make-vect 0.5 0)))
		(segments->painter 
			(vectors-to-connecting-segments (list left top right bottom left))))

(define frame-painter
	(let ((one .99)) ; for far borders, if you draw along 1, it doesn't show up (at least in DrRacket), need to do .99
		(let ((ll (make-vect 0 0)) 
				(ul (make-vect 0 one))
				(ur (make-vect one one))
				(lr (make-vect one 0)))
			(segments->painter  ; trace border clockwise
				(vectors-to-connecting-segments (list ll ul ur lr ll))))))


; Code from previous exercises that we'll need
define (make-vect x y)
	(cons x y)) ; just use a pair for now
(define (xcor-vect v)
	(car v))
(define (ycor-vect v)
	(cdr v))

(define (combine-vect op)
	(lambda (a b)
		(make-vect
			(op (xcor-vect a) (xcor-vect b))
			(op (ycor-vect a) (ycor-vect b)))))
(define add-vect (combine-vect +))
(define sub-vect (combine-vect -))

(define (scale-vect s v)
	(make-vect 
		(* s (xcor-vect v))
		(* s (ycor-vect v))))

(define (make-frame origin edge1 edge2)
	(cons origin (cons edge1 edge2)))
(define (origin frame) ; same as above
	(car frame))
(define (edge1 frame)  ; same as above
	(car (cdr frame)))
(define (edge2 frame)  ; don't need the leading car
	(cdr (cdr frame)))

(define (make-segment start end)
	(cons start end))
(define (start-segment s)
	(car s))
(define (end-segment s)
	(cdr s))