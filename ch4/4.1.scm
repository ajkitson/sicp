; Notice that we cannot tell whether the metacircular evaluator evaluates operands from left to right or from right to left. Its evaluation
; order is inherited from the underlying Lisp: If the arguments to cons in list-of-values are evaluated from left to right, then the 
; list-of-values will evaluate operands from left to right; and if the arguments to cons are evaluated from right to left, then list-of-values
; will evaluate operands from right to left.

; Write a version of list-of-values that evalutes operands from left to right regardless of the order of evaluation in the underlying
; Lisp. Also write a version of list-of-values that evaluates operands from right to left.
; ======
; Let's start by looking at the current definition of list-of-values:
(define (list-of-values exps env)
    (if (no-operands? exps)
        '()
        (cons (eval (first-operand exps) env)
              (list-of-values (rest-operands exps) env))))


; Here we can see why the underlying Lisp determines the evaluation order. If Lisp evaluates left to right, we'll evaluate
; (eval (first-operands exps) env) before recursively calling list of values. But if the underlying Lisp evaluates right to left
; then we dive back into list-of-values with the remaining operands before evaluating the first one, and doing that until we 
; get to the end and start unwinding, evaluating the last expression first.
;
; To control the order in which the expressions are evaluated, we need to separate out evaluating the expression from cons. 
; Now, the cons expression currently does three things:
; - evaluate the first expression in exps
; - recursively call list-of-values to retrieve the list of values the remaining expressions evaluate to 
; - cons these together into a list.
;
; We need to separate these steps in order to control the evaluation order. This means we need to store the return values from 
; evaluating the first expression and the list of the rest. How can we do that? Normally, we'd use let. Can we do that here?
; We can't, because we have the same issue with let that we do with cons--the order that the parameters to let are evaluated 
; will then determine the evaluation order. So instead we'll use let to create the pair that we return, then use set-car!
; and set-cdr! to set the car to the first value and the cdr to the remaining.

; Here's left to right:
(define (list-of-values exps env)
    (if (no-operands? exps)
        '()
        (let ((results (list 'temp 'temp)))
            (set-car! results (eval (first-operand exps) env))
            (set-cdr! results (list-of-values (rest-operands exps) env))
            results)))

; Now to get right to left, we just swap the set-c*r! lines
(define (list-of-values exps env)
    (if (no-operands? exps)
        '()
        (let ((results (list 'temp 'temp)))
            (set-cdr! results (list-of-values (rest-operands exps) env))
            (set-car! results (eval (first-operand exps) env))
            results)))


; To test these, we'll need some mock definitions for eval and the operands selectors and predicates? For now, we'll just have eval run
; whatever we give it. Also, we need a way to pass a list of expressions without them being evaluated before they get to our test. 
; We'll define procedures and pass a list of references. (This probably isn't how eval will really work--it shouldn't be. But
; it allows us to see whether we got the eval order correct).

(define (eval exp env) (exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

1 ]=> (define (a) (display 'a) 'a)
1 ]=> (define (b) (display 'b) 'b)
1 ]=> (define (c) (display 'c) 'c)

; Here's our left to right:
1 ]=> (list-of-values (list a b c) 'env)
abc
;Value 23: (a b c)

; And here's our right to left:
1 ]=> (list-of-values (list a b c) 'env)
cba
;Value 24: (a b c)

; Note that the printed value in right-to-left is indeed a right-to-left order, but the return list is still left-to-right, which is
; what we want in order to maintain the order of the expressions (otherwise we might mix up which values correspond to which expressions
; from the inital list.)



