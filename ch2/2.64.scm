; The following procedure list->tree converts an ordered list to a balanced binary tree. The helper proceudre partial-tree takes as 
; arguments an integer n and list of at least n elements and constructs a balanced tree containing the first n elements of the list.
; The result returned by partial-tree is a pair (formed with cons) whose car is the constructed tree and whose cdr is the list of 
; elements not included in the tree

(define (list->tree elements)
	(car (partial-tree elements (length elements))))

(define (partial-tree elts n)
	(if (= n 0)
		(cons '() elts)
		(let ((left-size (quotient (- n 1) 2)))
			(let ((left-result (partial-tree elts left-size)))
				(let ((left-tree (car left-result))
					(non-left-elts (cdr left-result))
					(right-size (- n (+ left-size 1))))
					(let ((this-entry (car non-left-elts))
						(right-result (partial-tree (cdr non-left-elts) right-size)))
					(let ((right-tree (car right-result))
						(remaining-elts (cdr right-result)))
					(cons (make-tree this-entry left-tree right-tree) remaining-elts))))))))

; a. Write a short paragraph explaining as clearly as you can how partial-tree works. Draw the tree produced by list->tree for the
; 	list (1 3 5 7 9 11).
; b. What is the order of growth in the number of steps required by list->tree to convert a list of n elements?
;
; =====
; a. partial-tree takes a list and builds a tree of the first n elements. It does this by dividing those n elements into three parts
; 	First, we have the first (n - 1) \ 2 elements, which will be used to build the left branch (itself a tree). partial-tree calls 
; 	itself recursively to do this. Then it grabs the middle element to be used as the entry for the tree and calls itself recursively
; 	to construct the right branch. It combines these using make-tree to return the tree. With each of these recursive calls to
; 	partial-tree, we do the same division into left-branch, entry, and right branch. Eventually, we hit the n = 0 case, in which
; 	case the branches are empty lists and we have a tree made up of an entry and two empty branches. Because left-size is 
; 	(n - 1) \ 2, if the elements can not be evenly split the right branch gets the extra element.
;
;	Note that the remaining-elts (the second element in the pair returned by partial tree) is just a handy way to get at the 
; 	right set of elements in the list. 
;
;	Here's the tree produced:
;	  5
;   /   \
; 1 	 9
;  \	/  \
;   3  7	11		
; 
; Confirming:
1 ]=> (list->tree '(1 3 5 7 9 11))
;Value 2: (5 (1 () (3 () ())) (9 (7 () ()) (11 () ())))
;
; b. The order of growth is O(n) because we need to construct a tree for every element in the list, but we don't visit a given 
; 	element more than once or create more than n trees, which would bump of the growth.
