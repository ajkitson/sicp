; Suppose we want to modify the differentiation program so that it works with ordinary mathematical notation, in which + and * are
; infix rather than prefix operators. Since the differentiation program is defined in terms of abstract data, we can modify it to work
; with different representations of expressions solely by changing the predicates, selectors, and constructors that define the 
; representation of the algebraic expressions on which the differentiator is to operate.

; a. Show how do do this in order to differentiate algebraic expressions presented in infix form, such as (x + (3 * (x + (y + 2))).
;	To simplify the task, assume that + and * always take two arguments and that expressions are fully parenthesized.
; 
; b. The problem becomes substantially harder if we allow standard algebraic notation, suce as (x + 3 * (x + y + 2)), which drops
; 	unnecessary parentheses and assumes that multiplication is done before addition. Can you design appropriate predicate, selectors,
;	and constructors for this notations such that our derivative program still works?

; =======
; For a, since we're only allowing two inputs, we can just modify the constructors, selectors, and predicates to put the operator
; second.
;
; For the predicates, we'll consolidate the checks in an expression-type? predicate that takes an expression and operator symbol
; and checks whether that operator is in the expression. That way, sum? and product? don't have to know or care whether we use
; infix notation or not. Only expression-type? needs to keep track of this.
(define (expression-type? exp op)
	(eq? (cadr exp) op)) ; op is second elem in exp if we're doing infix notation
(define (sum? exp)
	(expression-type? exp '+))
(define (product? exp)
	(expression-type? exp '*))

; Now we'll do the selectors. In 2.57, we abstracted get-inputs and last-inputs out of augend/multiplicand. This allowed us to 
; consolidate logic in getting the augent/multiplicand for expressions with more than two operands. We're back to two operands, but
; the abstraction will also help us convert to infix notation. We just need to update get-inputs and last-inputs and then 
; define addend and multiplier in terms of get-inputs. We don't need to touch augend or multiplicand. 
(define (get-inputs exp)
	(cons (car exp) (cddr exp))) ; return exp, minus second element
(define (last-inputs exp)
	(cadr (get-inputs exp))) ; have for now, while we only have two args for an expression
; since we're back to two arguments per expression, we'll simplify last-inputs, but leave the code in place since we might need it later
;	(let ((rest (cdr (get-inputs exp))))
		;(if (null? (cdr rest)) 
		;	(car rest) ; only one element in rest
		;	(cons (get-operator exp) rest))))  
(define (addend a)
	(car (get-inputs a)))
(define (multiplier a)
	(car (get-inputs a)))

(define (augend a)
	(last-inputs a))
(define (multiplicand a)
	(last-inputs a))


; And now we can update the constructors, just switching the operator placement in the final list operation
(define (make-sum a b)
  (cond ((=number? a 0) b)
        ((=number? b 0) a)
        ((and (number? a) (number? b)) (+ a b))
        (else (list a '+ b)))) ; now with infix operators

(define (make-product a b)
  (cond ((or (=number? a 0) (=number? b 0)) 0)
        ((=number? a 1) b)
        ((=number? b 1) a)
        ((and (number? a) (number? b)) (* a b))
	(else (list a '* b)))) ; now with infix operators


; Here we can see it still works for our derivative, now given an expression with infix notation:
1 ]=> (deriv '((x * y) * (x + 3)) 'x)
;Value 23: ((x * y) + ((x + 3) * y))


; b. We'll have to do a few things to drop unnecessary parens and add back the multiple args functionality. We'll need:
;	- a way to tell what the top-level operator is, given an expression that has multiple operators
; 		e.g. (3 + x * y) should be identified as a sum (of 3 and x * y), whereas (3 + x) * y is a product 
;	- a way to create expressions that do not have unnecessary parens (but DO have necessary parens)
; 		e.g. if the multiplier is x and the multiplicand is (y * z), it should produce x * y * z, BUT if the multiplicand
; 		is (y + z) we should get x * (y + z)
;  I think I'll stick with representing the augend and multiplicand as the last inputs of the top-level operator of the 
;  expression, with the operator applied to them. E.g. multiplicand of (x * y * z) is (y * z). The infix notation actually 
;  makes this easier than the prefix notation did. We'll just have to make sure that make-product and make-sum know when to 
;  remove the parens. OK, enough chatting. Let's write some code.

; First, let's create a way to tell what type of expression we're dealing with. We'll create get-operator, which takes an expression
; and tells you whether it's a sum or product or exponentiation. Note that this works a bit different from of order of operations. It
; tells you how to divvy up the parts of the expression at the top level, into sub-expressions that can be evaluated.
(define (get-operator exp) ; use in last-inputs and expression-type?
	(define (iter ops)
		(if (memq (car ops) exp)
			(car ops)
			(iter (cdr ops))))
	(iter '(+ * **)))

; now we just update expression-type? to use get-operator and our sum? and product? predicates are automatically updated:
(define (expression-type? exp op)
	(eq? (get-operator exp) op)) 

; Let's update get-inputs and last-inputs, which should allow the selectors to work. Actually, let's get rid of last-inputs. Now
; that we're using infix notation, we don't need to do anything special in last-inputs to make sure the right operator is applied,
; making it superfluous. Instead, get-inputs will return a list of two elements that correspond to the addend/multiplier and
; augend/multiplicand, with the augend/multiplicand potentially itself being an expression with the same operators as the 
; expression for which it is an augend/multiplicand. E.g. x + y + x -> '(x (y + z))
(define (get-inputs exp)
	(define (elems-until sym seq) ; get elements before a symbol, converse of memq, returns seq if sym not found 
		(if (or (null? seq) (eq? sym (car seq)))
			'()
			(cons (car seq) (elems-until sym (cdr seq)))))
	(define (elevate-one seq) ; if list only has one element (and therefore isn't an arithmetic expression), don't nest in a list
		(if (= (length seq) 1) (car seq) seq))
	(let ((op (get-operator exp)))
		(let ((first (elems-until op exp))
			(second (cdr (memq op exp))))
			(list (elevate-one first) (elevate-one second)))))

; now we just update augend and multiplicand to use get-inputs:
(define (augend a)
	(cadr (get-inputs a)))
(define (multiplicand a)
	(cadr (get-inputs a)))


; OK, now we can enter expressions without unnecessary parens and it'll understand the expression, but will produce output that 
; has unnecessary parens:
1 ]=> (deriv '(x * y * (x + 3)) 'x)
;Value 43: ((x * y) + (y * (x + 3)))

; We want this to be (x * y + y * (x + 3)). We'll have to update make-sum and make-product to recognize when it's inputs can 
; don't need to be nested. We'll do this by creating a build-exp procedure that centralizes this logic. 
(define (build-exp op left-exp right-exp)
	(define (not-list? x) (or (number? x) (symbol? x)))
	(define (needs-nesting? exp) ; only needs nesting if it's an expression and order of operations not clear
		(let ((order '(+ * **))) 
			(< (length (memq op order))
				(length (memq (get-operator exp) order)))))
	(let ((right-half 
			(if (or (not-list? right-exp) (needs-nesting? right-exp))
				(list op right-exp) 
				(cons op right-exp))))
		(if (or (not-list? left-exp) (needs-nesting? left-exp))
			(cons left-exp right-half)
			(append left-exp right-half))))

; OK, now let's use build-exp in make-sum and make-product.
(define (make-sum a b)
  (cond ((=number? a 0) b)
        ((=number? b 0) a)
        ((and (number? a) (number? b)) (+ a b))
        (else (build-exp '+ a b)))) ; now with infix operators

(define (make-product a b)
  (cond ((or (=number? a 0) (=number? b 0)) 0)
        ((=number? a 1) b)
        ((=number? b 1) a)
        ((and (number? a) (number? b)) (* a b))
	(else (build-exp '* a b)))) ; now with infix operators

; And in action:
1 ]=> (deriv '(x * y * (x + 3)) 'x)
;Value 69: (x * y + y * (x + 3))

; And now let's update our exponent procedures from 2.57:
(define (exponentiation? x)
	(and (expression-type? x '**)))
(define (base x) (car (get-inputs x)))
(define (exponent x) (cadr (get-inputs x)))
(define (make-exponentiation base exponent)
	(cond 
		((=number? exponent 0) 1)
		((=number? exponent 1) base)
		((and (number? base) (number? exponent)) (expt base exponent))
		(else (build-exp '** base exponent))))

; In action:
1 ]=> (deriv '(5 * (x ** 3)) 'x)
;Value 71: (5 * 3 * x ** 2)

; It would be nice if it combined 5 * 3 to be 15. I started adding it. I wrote a procedure to get the operands that were numbers
; and could be combined, then combine them (all the while, ingoring numbers that were part of a sub-expression e.g. 4 + 5 + 3 * x 
; should not add the 3). But then I had to also filter the other operands (variables, expressions) and make sure they were 
; combined with out numbers in the right way... it was getting unwieldy. Feels like it might be better to rethink how we deal with
; multiple operands at a lower level. E.g. allow make-sum and make-product to take lists of elements to add, and update the 
; selectors so they'll return lists of the input... Anyway, it was cumbersome to write a way to combine the numbers without
; reworking the basic stuff and I'm already anxious to get on to 2.59. Another case were I felt the limitations of the chosen 
; abstraction.




