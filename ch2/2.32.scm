; We can represent a set as a list of distinct elements, and we can represent the set of all subsets of the set as a list of lists. For
; example, if the set is (1 2 3), then the set of all subsets is (() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3)). Complete the following 
; definition of a procedure that generates the set of subsets of a set and give a clear explanation of why it works:

; (define (subsets s)
; 	(if (null? s)
; 		(list (list)) ; empty list... just (list) is ignored
; 		(let ((rest (subsets (cdr s))))
; 			(append rest (map <??> rest)))))
; ======
; This procedure is based on the insight all combinations of items in a set belong to one of two subsets: (a) sets that include the 
; first item in the original set and (b) sets that do not include the first item of the original subset. Now, we can calculate (a)
; by simply adding the first item to all the sets in (b). And we can calculate (b) recursively, splitting it into two subsets, one
; that includes sets that contain the first item in (b), and one that includes sets that do not. And so on.
;
; We define rest to contain all the sets in (b). The map call takes all the sets in b and adds the first item in the set on, making (a)

(define (subsets s)
	(if (null? s)
		(list (list)) ; empty list... just (list) is ignored
		(let ((rest (subsets (cdr s))))
			(append 
				rest 
				(map (lambda (x) (cons (car s) x)) rest)))))

1 ]=> (subsets (list 1 2 3))
;Value 11: (() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3))