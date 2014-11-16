; Make changes to the square limit of wave shown in figure 2.9 by working at each of the levels described above. In particular:
; a. Add some segments to the primitive wave painter of exercise 2.49 (to add a smile, for example).
; b. Change the pattern constructed by corner-split (for example, by using only one copy of the up-split and right-split images 
; 	instead of two).
; c. Modify the version of square-limit that uses square-of-four so as to assemple the corners in a different patterns. (For example,
; 	you might make the big Mr. Rogers look outwards from each corner of the square.)
; ======
; a. I'll take up the challenge to add a smile:
(define wave-painter 
	(segments->painter 
		(append 
			(vectors-to-connecting-segments ; smile
				(list (make-vect 0.42 0.85)
					(make-vect 0.5 0.8)
					(make-vect 0.58 0.85)))
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
             (vectors-to-connecting-segments ; upper left side
             	(list (make-vect 0.6 1)
             		(make-vect 0.65 0.85)
             		(make-vect 0.6 0.7)
             		(make-vect 0.7 0.7)
             		(make-vect 1 0.4)))
             (vectors-to-connecting-segments ; lower left side
             	(list (make-vect 1 0.2)
             		(make-vect 0.6 0.5)
             		(make-vect 0.7 0))))))

; b. And here's the update version of corner-split:
(define (corner-split2 painter n)
  (if (= n 0)
      painter
      (let ((up (up-split painter (- n 1)))
            (right (right-split painter (- n 1)))
            (corner (corner-split painter (- n 1))))
          (beside (below painter up)
                  (below right corner)))))

; c. and finally, the square-limit, updated so the painter rotates:
(define (square-limit painter n)
  (let ((combine4 (square-of-four rotate90 self rotate180 rotate270)))
    (combine4 (corner-split painter n))))

