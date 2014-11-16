; A two dimensional vector v running from the origin to a point can be represented as a pair consisting of an x-coordinate and a
; y-coordinate, Implement a data abstraction for vectors by giving a constructor make-vect and corresponding selectors xcor-vect
; and ycor-vect. In terms of your selectors and constructor, implement procedures add-vect, sub-vect, and scale-vect that perform
; the operations of vector addition, subtraction, and multiplying a vector by a scalar:

; (x1, y1) + (x2, y2) = (x1 + x2, y1 + y2)
; (x1, y1) - (x2, y2) = (x1 - x2, y1 - y2)
; s * (x, y) = (sx, sy)
; =====
; Here is our constructor and our selectors. Just storing the vector as a pair.
(define (make-vect x y)
	(cons x y)) ; just use a pair for now
(define (xcor-vect v)
	(car v))
(define (ycor-vect v)
	(cdr v))

; now our arithmetic operations:
(define (add-vect a b)
	(make-vect
		(+ (xcor-vect a) (xcor-vect b))
		(+ (ycor-vect a) (ycor-vect b))))

; actually, I see subtraction is going to be the same pattern, with a - instead of a plus. Let's create an abstraction:
(define (combine-vect op a b)
	(make-vect
		(op (xcor-vect a) (xcor-vect b))
		(op (ycor-vect a) (ycor-vect b))))

(define (add-vect a b)
	(combine-vect + a b))
(define (sub-vect a b)
	(combine-vect - a b))

; these also work. I like them a little better
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

; in action:
1 ]=> (define a (make-vect 1 2))
1 ]=> (define b (make-vect 3 4))
1 ]=> (add-vect a b)
;Value 3: (4 . 6)
1 ]=> (add-vect b a)
;Value 4: (4 . 6)

1 ]=> (sub-vect b a)
;Value 5: (2 . 2)
1 ]=> (sub-vect a b)
;Value 6: (-2 . -2)

1 ]=> (scale-vect 5 a)
;Value 8: (5 . 10)
1 ]=> (scale-vect 5 b)
;Value 9: (15 . 20)

; and now some combos. a - b + b = a
1 ]=> (add-vect (sub-vect a b) b)
;Value 10: (1 . 2)

; 100(b - a) + a
1 ]=> (add-vect (scale-vect 100 (sub-vect b a)) a)
;Value 13: (201 . 202)


