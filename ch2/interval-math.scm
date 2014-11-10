
(define (make-interval a b)
	(cons a b))
(define (upper-bound a)
	(cdr a))
(define (lower-bound a)
	(car a))
(define (add-interval a b)
	(make-interval (+ (lower-bound a) (lower-bound b))
		(+ (upper-bound a) (upper-bound b))))
(define (sub-interval a b)
	(make-interval 
		(- (lower-bound a) (upper-bound b))
		(- (upper-bound a) (lower-bound b))))

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


(define (mul-interval a b)
	(let ((p1 (* (lower-bound a) (lower-bound b)))
			(p2 (* (lower-bound a) (upper-bound b)))
			(p3 (* (upper-bound a) (lower-bound b)))
			(p4 (* (upper-bound a) (upper-bound b))))
	(make-interval (min p1 p2 p3 p4) (max p1 p2 p3 p4))))

(define (div-interval a b)
	(if (and (< (lower-bound b) 0)
			(> (upper-bound b) 0))
		(error "Error: cannot divide by an interval that spans zero.")
		(mul-interval 
			a 
			(make-interval 
				(/ 1.0 (upper-bound b)) 
				(/ 1.0 (lower-bound b))))))

(define (par1 r1 r2)
	(div-interval 
		(mul-interval r1 r2) 
		(add-interval r1 r2)))

(define (par2 r1 r2)
	(let ((one (make-interval 1 1)))
		(div-interval 
			one
			(add-interval
				(div-interval one r1)
				(div-interval one r2)))))
