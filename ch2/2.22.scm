; Louis Reasoner tries to write the first square-list procedure of exercise 2.21 so that it evolves an iterative process:
; (define (square-list items)
; 	(define (iter things answer)
; 		(if (null? things)
; 			answer
; 			(iter 
; 				(cdr things)
; 				(cons 
; 					(square (car things))
; 					answer))))
; 	(iter items (list)))
;
; Unfortunately, defining square-list this way produces the answer list in the revers order of the one desired. Why?
;
; Louis then tries to fix hiw bug by interchanging the arguments to cons:
; (define (square-list items)
; 	(define (iter things answer)
; 		(if (null? things)
; 			answer
; 			(iter 
; 				(cdr things)
; 				(cons 
; 					answer
; 					(square (car things))))))
; 	(iter items (list)))
;
; This doesn't work either. Explain.
; ======
; Ah, I ran into this, too, in my first implementation of filter in 2.20. The reason the first implementation of square-list prints
; reverse order is that you're always pulling from the front of the input list and adding to the front of the output list. This means
; that the items you pull off the input list first will, as you take more items off the list and move them to the output list, get 
; pushed further and further back in the output list.
; 
; Now the reason Louis' second attempt doesn't work is that the first and second arguments to cons are not interchangeable. The first
; argument to cons becomes the first item on the resulting list. If the first argument is itself a list, then the first item on the 
; resulting list is the list you fed to cons. The second item is a list to which the  first argument to cons is prepended. So, Louis' 
; new implementation yields a set of nested lists, not a single list of squares.