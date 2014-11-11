; A binary mobile consists of two branches, a left branch and a right branch. Each branch is a rod of a certain length, from which hangs
; either a weight or another binary mobile. We can represent a binary mobile using compound data by constructing it from two branches (for
; example, using list):
;
; (define (make-mobile left right)
; 	(list left right))
;
; A branch is constructed from a length (which must be a number) together with a structure, which may be either a number (representing a
; simple weight) or another mobile:

; (define (make-branch length structure)
; 	(list length structure))
;
; a. Write the corresponding selectors left-branch and right-branch, which return the branches of a mobile, and branch-length and
; branch-structure, which return the components of a branch.
; =====
; We'll write a little utility to get the right side of a two item list:
(define (get-second l)
	(car (cdr l)))

(define (left-branch mobile)
	(car mobile))

(define (right-branch mobile)
	(get-second mobile))

(define (branch-length branch)
	(car branch))

(define (branch-structure branch)
	(get-second branch))


; b. Using your selectors, define a procedure total-weight that returns the total weight of a mobile. 
; ====
; Basically, we just recursively add the weight of each branch of the mobile, with our base case being when the structure is actually
; a weight and not a mobile.

(define (is-mobile? structure) ; define this out here so we can adjust later if mobile implementation changes
	(pair? structure))

(define (total-weight struct)
	(if (not (is-mobile? struct)) ; if not a mobile, then it's a weight
		struct
		(+ (total-weight (branch-structure (left-branch struct)))
			(total-weight (branch-structure (right-branch struct))))))

1 ]=> (define a (make-mobile (make-branch 10 5) (make-branch 10 20)))
1 ]=> (define b (make-mobile (make-branch 3 32) (make-branch 8 12)))
1 ]=> (define c (make-mobile (make-branch 10 a) (make-branch 20 b)))
1 ]=> c
;Value 45: ((10 ((10 5) (10 20))) (20 ((3 32) (8 12))))
1 ]=> (total-weight c)
;Value: 69

; and it works!



; c. A mobile is said to be balanced if the torque applied by its top-left branch is equal to that applied by its top-right branch (that
; is, if the length of the left rod multiplied by the weight hanging from that rod is equal to the corresponding product for the right
; side) and if each of the submobiles hanging off its branches is balanced. Design a predicate that tests whether a binary mobile is
; balanced.
(define (balanced? struct)
	(define (torque branch)
		(* (branch-length branch)
			(total-weight (branch-structure branch))))
	(if (not (is-mobile? struct))
		true
		(let 
			((left (left-branch struct))
			(right (right-branch struct)))
			(and (= (torque left) (torque right))
				(and (balanced? (branch-structure left))
					(balanced? (branch-structure right)))))))

; This works, too:
1 ]=> (define a (make-mobile (make-branch 3 4) (make-branch 2 6))) ; torque of 12 on each side
1 ]=> (balanced? a)
;Value: #t

1 ]=> (define b (make-mobile (make-branch 2 8) (make-branch 4 4))) ; torque of 16 on each side
1 ]=> (balanced? b)
;Value: #t

1 ]=> (define c (make-mobile (make-branch 10 a) (make-branch 5 b))) ; unbalanced, torques of 100 and 60
1 ]=> (total-weight a)
;Value: 10
1 ]=> (total-weight b)
;Value: 12
1 ]=> (balanced? c)
;Value: #f

1 ]=> (define c (make-mobile (make-branch 6 a) (make-branch 5 b))) ; now balanced, torque of 60 on each side
1 ]=> (balanced? c)
;Value: #t


; d. Suppose we change the representation of mobiles so that the constructors are 

; (define (make-mobile left right)
; 	(cons left right))
; (define (make-branch length structure)
; 	(cons length structure))

; How much do you need to change your programs to convert to the new representation?
; =====
; Not much at all. We'd just have to change the get-right procedure that the right-branch and branch-structure selectors use. 
; Old version:
(define (get-second l)
	(car (cdr l)))

; New version:
(define (get-second l)
	(cdr l))	; since (cdr <pair>) doesn't return a list, we don't need to grab the car.


