; Recall the special forms *and* and *or* from chapter 1:
; - and: The expressions are evaluated from left-to-right. If any expression
;   evaluates to false, false is returned; any remaining expressions are not
;   evaluated. If all the expressions evaluate to true values, the value of
;   the last expression is returned. If there are no expressions then true is
;   returned.
;
; - or: The expressions are evaluated from left to right. If any expression
;   evaluates to a true value, that value is returned; any remaining expressions
;   are not evaluated. If all expressions evaluate to false, or if there are no
;   expressions, then false is returned.

; Install and and or as new special forms for the evaluator by defining
; appropriate syntax procedures and evaluation procedures eval-and and eval-or.
; Alternatively, show how to implement eval and or as derived expressions.
; ========
; Cool! We'll do the special-form version first and add them to the type system.
; Then try doing derived expressions and converting them into something else.
;
; Here's eval-and. We need to store the values so we can return them if true
; without evaluating the expressions again. Also, we need to consider the case
; of more than 2 expressions. We'll model this after eval-sequence.


(define (and? exp) (tagged-list? exp 'and))
(define (eval-and exp env)
  (define (expand-and exp)
    (let ((first (eval (car exp) env)))
      (if (not (true? first))
        'false
        (if (null? (cdr exp))
          first
          (expand-and (cdr exp))))))
  (if (null? (cdr exp))
    'true   ; no expressions => true
    (expand-and (cdr exp))))

; eval-or is similar, but since the no-operand case and no-match case return
; false, we can handle those together
(define (or? exp) (tagged-list? exp 'or))
(define (eval-or exp env)
  (define (expand-or exp)
    (if (null? exp)
      'false
      (let ((first (eval (car exp) env)))
        (if (true? first)
          first
          (expand-or (cdr exp))))))
  (expand-or (cdr exp)))

; and it works!
1 ]=> (eval '(and) the-global-environment)
;Value: #t
1 ]=> (eval '(and 1) the-global-environment)
;Value: 1
1 ]=> (eval '(and 1 2) the-global-environment)
;Value: 2
1 ]=> (eval '(and 1 false) the-global-environment)
;Value: #f
1 ]=> (eval '(and false 2) the-global-environment)
;Value: #f
1 ]=> (eval '(and false false) the-global-environment)
;Value: #f
1 ]=> (eval '(and 1 2 3 4) the-global-environment)
;Value: 4
1 ]=> (eval '(or) the-global-environment)
;Value: #f
1 ]=> (eval '(or 1) the-global-environment)
;Value: 1
1 ]=> (eval '(or 1 2) the-global-environment)
;Value: 1
1 ]=> (eval '(or 1 false) the-global-environment)
;Value: 1
1 ]=> (eval '(or false 2) the-global-environment)
;Value: 2
1 ]=> (eval '(or false false) the-global-environment)
;Value: #f
1 ]=> (eval '(or 1 2 3) the-global-environment)
;Value: 1



; Alrighty. Now let's do the derived expressions. It's a bit trickier than it
; might seem at first. This is because above we were able to use let to save
; off the value of the expression we were evaluating so we wouldn't evaluate
; a second time in case it turned out to be the return value. Here, however,
; we can't use a normal let--if we did, it would either evaluate the expression
; too early (i.e. not wait until the full derived expresion was evaluated, as
; in (let ((first (eval (car exp) env)))) ...). That's not good.
;
; Instead, we'll use a lambda to evaluate the expression once, the derived
; version of this:
; ((lambda (exp)
;    (if exp exp (try (rest exps))))
;   (car exps))
; This way, the exp is evaluated once on being passed as the argument to the
; lambda. However, we'll have to skip ahead a bit to where we have a way to
; construct lambdas (later in the chapter)

; We'll need a way to construct if statements, which the book provides:
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

; And our lambda
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body))) ; '(lambda (parameters...) exp1 exp2...)

; A lambda is evaluated by having it be the first element in a list with the
; args as the remaining elements: ((lambda (a b) (+ a b)) 4 5) => 9

; For and, it's only the last expression that we would pass to the lambda...
(define (and->if exps)
  (if (null? (cdr exps))
    (list                    ; if last expression, feed into lambda
      (make-lambda '(exp)    ; << body
        (list (make-if 'exp 'exp 'false)))
      (car exps))            ; << arg
    (make-if (car exps)      ; otherwise, continue expanding
      (and->if (cdr exps))
      'false)))

; For or, we need to feed each expression through the lambda since we need to
; return it if it is truthy
(define (or->if exps)
  (if (null? exps)
    'false
    (list
      (make-lambda
        '(x)
        (list (make-if 'x 'x (or->if (cdr exps)))))
      (car exps))))

; Then we slip these lines into eval:
(cond ((self-evaluating? exp) exp)
      ;....
      ((and? exp) (eval (and->if (cdr exp)) env))
      ((or? exp)  (eval (or->if  (cdr exp)) env))
      ;...
      )

; And in action: (note that we're not handling the case were and receives no
; expressions)
(eval '(and 1) the-global-environment)
;Value: 1
(eval '(and 1 2) the-global-environment)
;Value: 2
(eval '(and 1 false) the-global-environment)
;Value: #f
(eval '(and false 2) the-global-environment)
;Value: #f
(eval '(and false false) the-global-environment)
;Value: #f
(eval '(and 1 2 3 4) the-global-environment)
;Value: 4
(eval '(or) the-global-environment)
;Value: #f
(eval '(or 1) the-global-environment)
;Value: 1
(eval '(or 1 2) the-global-environment)
;Value: 1
(eval '(or 1 false) the-global-environment)
;Value: 1
(eval '(or false 2) the-global-environment)
;Value: 2
(eval '(or false false) the-global-environment)
;Value: #f
2 error> (eval '(or 1 2 3) the-global-environment)
;Value: 1



