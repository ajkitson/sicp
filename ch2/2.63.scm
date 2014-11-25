; ; Each of the following two procedures converts a binary tree to a list.

(define (tree->list-1 tree)
	(if (null? tree)
		'()
		(append (tree->list-1 (left-branch tree))
			(cons (entry tree)
				(tree->list-1 (right-branch tree))))))

(define (tree->list-2 tree)
	(define (copy-to-list tree result-list)
		(if (null? tree)
			result-list
			(copy-to-list 
				(left-branch tree)
				(cons (entry tree)
					(copy-to-list (right-branch tree) result-list)))))
	(copy-to-list tree '()))
; 
; a. Do the two procedures produce the same result for every tree? If not, how do the results differ? What lists do the two procedures
;	produce for the trees in figure 2.16?
;
; b. Do the two procedures have the same order of growth in the number of steps required to convert a balanced tree with n elements
; 	to a list? If not, which one grows more slowly?
;
; ======
; a. Let's start with the last part of the question and work with the figures in 2.16. They were:
; 		7						3								5	
; 	  /	  \					  /	  \							  /	  \
; 	3		9				1 		7						3		9
;  /  \		  \					  /   \					   /	  /   \
; 1 	5		11				5		9				  1		 7 	   11	
; 										  \
; 										  11
; Working left to right we get...
; tree->list-1:
; (1 3 5 7 9 11)
; (1 3 5 7 9 11)
; (1 3 5 7 9 11)
;
; tree->list-2:
; This one is tougher to just look at and figure out. Let's use the substitution method:
; (copy-to-list 7... '())
; (copy-to-list 3... (cons 7 (copy-to-list 9... '())))
; (copy-to-list 3... (cons 7 (copy-to-list '() (cons 9 (copy-to-list 11 ... '())))))
; (copy-to-list 3... (cons 7 (copy-to-list '() (cons 9 (cons 11 (copy-to-list '() '()))))))
; (copy-to-list 3... (cons 7 (copy-to-list '() (cons 9 (11))))))
; (copy-to-list 3... (cons 7 (copy-to-list '() (9 11))))
; (copy-to-list 3... (cons 7 (9 11)))
; (copy-to-list 3... (7 9 11))
; (copy-to-list 1... (cons 3 (copy-to-list 5... (7 9 11))))
; (copy-to-list 1... (cons 3 (copy-to-list '() (cons 5 (copy-to-list '() (7 9 11))))))
; (copy-to-list 1... (3 5 7 9 11))
; (1 3 5 7 9 11)
;
; And now that I've worked through that once I can see that the rest are going to be the same. Because this implementation, like 
; the other, is just the current entry sandwiched between the left and right branches, which are each just their respective entry
; sandwiched between their respective left and right branches.
; 
; We can create the trees manually and get the same result. Creating the trees was much less tedious than I thouhgt it would be.
1 ]=> (define tree1 '(7 (3 (1 () ()) (5 () ())) (9 () (11 () ()))))
1 ]=> (tree->list-2 tree1)
;Value 27: (1 3 5 7 9 11)

1 ]=> (define tree2 '(3 (1 () ()) (7 (5 () ()) (9 () (11 () ())))))
1 ]=> (tree->list-2 tree2)
;Value 28: (1 3 5 7 9 11)

1 ]=> (define tree3 '(5 (3 (1 () ()) ()) (9 (7 () ()) (11 () ()))))
1 ]=> (tree->list-2 tree3)
;Value 29: (1 3 5 7 9 11)

1 ]=> (tree->list-1 tree1)
;Value 30: (1 3 5 7 9 11)

1 ]=> (tree->list-1 tree2)
;Value 31: (1 3 5 7 9 11)

1 ]=> (tree->list-1 tree3)
;Value 32: (1 3 5 7 9 11)


; b. Do these have the same order of growth? Maybe? Close? The second one just cons-s everything together. The first one uses
; 	append to join left and right halves. Although each of these is performed once, cons is a primitive whereas append is a series 
; 	of nested cons-s, one for each element in the first list (or, in this case, the lefthand tree). Now, if the built-in 
; 	implementation has optimized append in some way they could be roughly equal.
;
; When I tested each with a tree of 10k and 20K elements, they ran in the same time:

1 ]=> (define t (list->tree (enumerate-interval 1 10000)))
1 ]=> (test tree->list-1 t)
2.0000000000000018e-2
1 ]=> (test tree->list-2 t)
1.9999999999999796e-2

1 ]=> (define t (list->tree (enumerate-interval 1 20000)))

1 ]=> (test tree->list-1 t)
4.0000000000000036e-2
1 ]=> (test tree->list-2 t)
4.0000000000000036e-2

; Fewer than 10k elements wouldn't register a time (just 0), and I couldn't easily create trees with more than 20k elements without
; hitting max recursion depth.

; Here's the timing wrapper (I tested some other code to make sure 4.0000...e-2 wasn't just the time it takes this code to run):
(define (test fn arg)
	(let ((time (runtime)))
		(fn arg)
		(display (- (runtime) time))))




