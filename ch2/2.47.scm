; Here are two possible constructors for frames:
;
; (define (make-frame origin edge1 edge2)
; 	(list origin edge1 edge2))
;
; (define (make-frame origin edge1 edge2)
; 	(cons origin (cons edge1 edge2)))
;
; For each constructor supply the appropriate selectors to produce the implementation for frames.
; ======
; Will be good to review the difference between list and nested cons-s. Hasn't become entirely natural yet.

; Let's start with the list implementation:
(define (make-frame origin edge1 edge2)
	(list origin edge1 edge2))

(define (origin frame)
	(car frame))
(define (edge1 frame)
	(car (cdr frame)))
(define (edge2 frame)
	(car (cdr (cdr frame))))

; In action:
1 ]=> (define v1 (make-vect 1 2))
1 ]=> (define v2 (make-vect 3 4))
1 ]=> (define v3 (make-vect 5 6))
1 ]=> (define f (make-frame v1 v2 v3))
1 ]=> (origin f)
;Value 28: (1 . 2)
1 ]=> (edge1 f)
;Value 29: (3 . 4)
1 ]=> (edge2 f)
;Value 30: (5 . 6)

; And now with the nested cons. It's really the same as above. The big thing is that the last item (second item on most deeply 
; nested pair) is not itself a pair so we don't use car for edge2
(define (make-frame origin edge1 edge2)
	(cons origin (cons edge1 edge2)))
(define (origin frame) ; same as above
	(car frame))
(define (edge1 frame)  ; same as above
	(car (cdr frame)))
(define (edge2 frame)  ; don't need the leading car
	(cdr (cdr frame)))

; As expected
1 ]=> (origin f)
;Value 28: (1 . 2)
1 ]=> (edge1 f)
;Value 29: (3 . 4)
1 ]=> (edge2 f)
;Value 30: (5 . 6)



