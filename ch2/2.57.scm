; Extend the differentiation program to handle sums and products of arbitrary numbers of (two or more) terms. Then the last example
; above could be expressed as (derive '(* x y (+ x 3)) 'x'). Try to do this by changing only the representation for sums and products
; without changing the deriv procedure at all. For example, the addend of a sum would be the first term, and the augend would be the 
; sum of the rest of the terms.
; ======
; We should be able to do this, as suggested, by treating the addend as the first term and the augend as the sum of the remaining
; terms. Augend will call make-sum on the caddr of its input. Additionally, we'll enhance make-sum to check if the expression it
; is adding is a sum, and, if so, append it's elements so that we don't end up with a bunch of nested sums. Multiplication is 
; analogous.
;
; ... actually, I started and found that in updating make-sum and make-product to handle reducing nested sums and products, I was
; getting ahead of myself. That's in 2.58, so I moved the (incomplete) work there.
;
; The only changes for 2.57 are to augend and multiplicand. I added get-inputs last-inputs. and like the abstraction. I think 
; that'll help later when we allow the expressions to use infix notation. I tried using make-product and make-sum to join the 
; result of last-inputs, but it was becoming more complicated than it was worth. Now, I basically just remove the first
; input of the expression and return the rest, so not simplifying anything as I'd hoped make-sum/product might, but also not
; adding any complexity.

(define (augend a)
	(last-inputs a))
(define (multiplicand a)
	(last-inputs a))

; takes expression and returns all inputs/operands but the first input. If there are exactly two inputs, then the 2nd input is returned. If
; there are more than two, all inputs except the first are returned, but as an expression where the operator is the same as that
; of the original expression.
; (+ 1 2) --> 2
; (+ 1 2 3 4) --> (+ 2 3 4)
(define (last-inputs exp)
	(let ((rest (cdr (get-inputs exp))))
		(if (null? (cdr rest)) 
			(car rest) ; only one element in rest
			(cons (car exp) rest))))
(define (get-inputs exp)
	(and (pair? exp) (cdr exp)))

; And in action on our derivative example:
1 ]=> (deriv '(* x y (+ x 3)) 'x)
;Value 22: (+ (* x y) (* y (+ x 3)))