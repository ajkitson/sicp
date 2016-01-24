; Louis Reasoner plans to reorder the cond clauses in eval so that the clause
; for procedure applications appears before the clause for assignments. He
; argues that this will make the interpreter more efficient: Since programs
; usually contain more applications than assignments, definitions, and so on,
; his modified eval will usually check fewer clauses than the original eval
; before identifying the type of an expression.

; a. What is wrong with Louis' plan? (Hint: What will Louis' evaluator do
;    with the expression (define x 3)?)

; b. Louis is upset that his plan didn't work. He is willing to go to any
;    length to make his evaluator recognize procedure applications
;    before it checks for most other kinds of expressions. Help him by
;    changing the syntax of the evaluated language so that procedure
;    applications start with call. For example, instead of (factorial 3)
;    we will now have to write (call factorial 3) and instead of (+ 1 2)
;    we will have to write (call + 1 2).
; ======
; This got at something I was wondering about when I first read the definition
; of application? Here's the definition:

(define (application? exp) (pair? exp))

; It just checks whether we have a pair. That seems fragile since it only works
; if we have application? as our last check. This is because all of the other
; expression types are also represented as pairs and will pass this test. So
; if we put it first, we never get to the other checks--everything passes
; the application? check and is treated as a procedure application. Not good.
;
; b. We'll help Louis update eval so it'll evaluate procedure application first.
;    We need a way to indicate that an exp is a procedure application
;    (previously it was procedure application if it wasn't anything else).
;    So we use the 'call tag.
;
; We'll start by moving the application check up in eval. We'll omit the other
; type checks for brevity, except self-evaluating? since we need to eventually
; get down to the primitives so we can combine them.

(define (eval exp env)
  (cond
    ((application? exp)
      (apply (eval (operator exp) env)
             (list-of-values (operands exp) env)))
    ((self-evaluating? exp) exp)
    ; ... all the other checks ...
    ))

; Now we need to update the selectors to account for the new 'call tag
; (car -> cadr, cdr -> cddr):
(define (operator exp) (cadr exp))
(define (operands exp) (cddr exp))

; And of course, have application? check for the 'call tag, using tagged-list:
(define (application? exp) (tagged-list exp 'call))
(define (tagged-list exp tag)
    (if (pair? exp)
        (eq? (car exp) tag)
        false))

; Oh, and can't forget self-evaluating?! I'm adding a procedure? check to it...
; We won't need this once we implement the data-directed version, but the
; book so far has only halfway implemented the apply step and this let's
; us easily pretend we've got the full implementation
(define (self-evaluating? exp)
    (cond
        ((number? exp) true)
        ((string? exp) true)
        ((procedure? exp) true)
        (else false)))

; Now we can pass eval an expression list, tagged with 'call, and it works:
1 ]=> (eval (list 'call + 1 2 3) 'env)
;Value: 6

1 ]=> (eval (list 'call list 1 2 3) 'env)
;Value 26: (1 2 3)

; Or doesn't work, as appropriate (we expect this to fail)
1 ]=> (eval (list 'call display 1 2 3) 'env)
;The object 2, passed as an argument to display, is not an output port.




