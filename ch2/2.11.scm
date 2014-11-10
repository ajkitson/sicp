; In passing, Ben also cryptically comments: "By testing the signs of the end-points of the intervals, it is possible to break 
; mul-interval into nine cases, only one of which require more than two multiplications." Rewrite this procedure using Ben's suggestion.
; ====
; What does Ben mean? Let's take a look at mul-interval as it stands:

(define (mul-interval a b)
	(let ((p1 (* (lower-bound a) (lower-bound b)))
			(p2 (* (lower-bound a) (upper-bound b)))
			(p3 (* (upper-bound a) (lower-bound b)))
			(p4 (* (upper-bound a) (upper-bound b))))
	(make-interval (min p1 p2 p3 p4) (max p1 p2 p3 p4))))

; First, notice that we're doing 4 multiplications with each mul-interval call. Do we need all these? At first, I didn't understand
; when we would ever need p2 or p3. Wouldn't the min always be the lower bound of both intervals? Then I realized that if  the lower
; bound of each interval were negative, multiplying them would yield a positive number that could be larger than the product of the
; upper bounds. This, I think, is what Ben is getting at. If the lower bounds are both positive, then we know that their product will
; be lower than the product of any other pair of bounds. If the upper bounds are both negative, the lower bounds must both be an 
; even greater negative number (farther away from zero), so the product of the two upper bounds will be the new lower bound in this
; case. 
;
; Here are the cases we have:
; - both intervals are entirely positive  --> lb: p1, ub: p4
; - both intervals are entirely negative  --> lb: p4, ub: p1
; - one interval is negative, the other is positive (2 ways) a < 0: (lb: p2, ub: p3), reversed if b < 0 
; - one interval spans zero, other is positive (2 ways): if a spans 0: (lb: p2, ub: p4), reversed if b < 0
; - one interval spans zero, other is negative (2 ways): if a spans 0: (lb: p3, ub: p1), reversed if b < 0
; - both intervals span zero --> lb: either p2 or p3, ub: either p1 or p4
;
; Writing the below was tedious and I don't see why saving a couple multiplications was worth it. They can't be that inefficient, 
; can they? Or are the min and max operations so bad? Beyond the tedium, we introduce a bunch of conditions to check so it's not
; like this is for free. Anyway, I'm ready to move on.



(define (mul-interval a b)
	(define (positive i)
		(if (> (lower-bound i) 0)
			true
			false))
	(define (negative i)
		(if (< (upper-bound i) 0)
			true
			false))
	(define (spans-zero i)
		(not (or (positive i) (negative i))))
	(cond 
		((and (positive a) (positive b))			; both positive --> p1, p4
			(make-interval
				(* (lower-bound a) (lower-bound b))
				(* (upper-bound a) (upper-bound b))))
		((and (negative a) (negative b))			; both negative --> p4, p1
			(make-interval 
				(* (upper-bound a) (upper-bound b))
				(* (lower-bound a) (lower-bound b))))
		((and (negative a) (positive b))			; a negative, b positive --> p2, p3
			(make-interval
				(* (lower-bound a) (upper-bound b))
				(* (upper-bound a) (lower-bound b))))
		((and (positive a) (negative b))			; a positive, b negative --> p3, p2
			(make-interval 
				(* (upper-bound a) (lower-bound b))
				(* (lower-bound a) (upper-bound b))))
		((and (spans-zero a) (positive b))			; a spans 0, b positive --> p2, p4
			(make-interval 
				(* (lower-bound a) (upper-bound b))
				(* (upper-bound a) (upper-bound b))))
		((and (positive a) (spans-zero b))			; a positive, b spans 0 --> p3, p4
			(make-interval
				(* (upper-bound a) (lower-bound b))
				(* (upper-bound a) (upper-bound b))))
		((and (spans-zero a) (negative b))
			(make-interval
				(* (upper-bound a) (lower-bound b))
				(* (lower-bound a) (lower-bound b))))
		((and (negative a) (spans-zero b))
			(make-interval
				(* (lower-bound a) (upper-bound b))
				(* (lower-bound a) (lower-bound b))))
		(else 										; both span 0
			(make-interval 
				(min 
					(* (lower-bound a) (upper-bound b))
					(* (upper-bound a) (lower-bound b)))
				(max
					(* (lower-bound a) (lower-bound b))
					(* (upper-bound a) (upper-bound b)))))))



