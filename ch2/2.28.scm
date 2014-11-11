; Write a procedure frince that takes as argument a tree (represented as a list) and returns a list whose elements are all the leaves of
; the tree arranged in left-to-right order. For example:

; (define x (list (list 1 2) (list 3 4)))

; (fringe x)
; (1 2 3 4)

; (fringe (list x x))
; (1 2 3 4 1 2 3 4)
;
; =========
; Here we use append to join the lists without nesting. It's been used several times in the text, but not implemented:

(define (fringe tree)
	(if (null? tree)
		(list)
		(let ((item (car tree)))
			(if (not (pair? item))
				(cons item (fringe (cdr tree)))
				(append (fringe item) (fringe (cdr tree)))))))

; And this one, which I like a little better since it uses append in all cases, but to do so it converts leaf nodes to lists
(define (fringe tree)
	(if (null? tree)
		(list)
		(let ((item (car tree)))
			(append
				(if (not (pair? item)) (list item) (fringe item))
				(fringe (cdr tree))))))

1 ]=> (fringe x)
;Value 36: (1 2 3 4)

1 ]=> (fringe (list x x))
;Value 37: (1 2 3 4 1 2 3 4)

; And since we haven't implemented append, let's do so now. 
(define (append a b)
	(if (null? a)
		b
		(cons (car a) (append (cdr a) b))))