; Abtract your answer to exercise 2.30 to produce a procedure tree-map with the property that square-tree could be defined as:
; (define (square-tree tree) (tree-map square tree))
; =====
; I knew this is where we were headed :) Glad to finally get here. Should have done this for 2.29.
; Anyway, here we go:
(define (tree-map fn tree)
	(map (lambda (x)
			(if (not (pair? x))
				(fn x)
				(tree-map fn x)))
		tree))