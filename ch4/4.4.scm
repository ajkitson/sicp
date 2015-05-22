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
; without evaluating the expressions again. And I was tempted to just return
; the second value if the first was true (since whether the second evaluates to
; true or false determines the return values) but in the false case, we wouldn't
; actually be returning false as a value, but the return value, which might
; just be falsey and not actually false. So we wrap that in a let statement, too.

(define (eval-and exp env)
    (let ((first (eval (car exp) env)))
        (if (true? first)
            (let ((second (eval (cadr exp) env)))
                (if (true? second)
                    second
                    'false))
            'false)))

; eval-or is similar
(define (eval-or exp env)
    (let ((first (eval (car exp) env)))
        (if (true? first)
            first
            (let ((second (eval (cadr exp) env)))
                (if (true? second)
                    second
                    'false)))))

; Now we put them in the table:
(put 'and 'eval eval-and)
(put 'or 'eval eval-or)

; and it works!
1 ]=> (eval (list 'and 'a 'b) 'env)
;Value: b
1 ]=> (eval (list 'or 'a 'b) 'env)
;Value: a
1 ]=> (eval (list 'or 'a 'false) 'env)
;Value: a
1 ]=> (eval (list 'and 'a 'false) 'env)
;Value: #f
1 ]=> (eval (list 'or 'false 'b) 'env)
;Value: b
1 ]=> (eval (list 'or 'false 'false) 'env)
;Value: #f

; We could also have use the underlying 'and' and 'or' operators of the
; underlying scheme since they make the same evaluation order guarantees as the
; version of scheme we're interpreting... but that would have been boring.
;
; Alrighty. Now let's do the derived expressions. The difference here is that
; instead of using the underlying if, as above, we'll use the if defined in our
; interpreter.

; We'll need a way to construct if statements, which the book provides:
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

; Now we can define a procedure that turns an 'and' expression into the
; equivalent if expression.
(define (and->if exp)
  (let ((first (car exp))
        (second (cadr exp)))
    (make-if first (make-if second second 'false) 'false)))

; Ditto for or
(define (or->if exp)
  (let ((first (car exp))
        (second (cadr exp)))
  (make-if first first (make-if second second 'false))))

; Now we just define eval-and and eval-or in terms of their if versions.
(define (eval-and exp env)
  (eval (and->if exp) env))
(define (eval-or exp env)
  (eval (or->if exp) env))

; Have to put them in the table, of course:
(put 'and 'eval eval-and)
(put 'or 'eval eval-or)


; And tada! It works:
1 ]=> (eval (list 'or 'a 'b) 'env)
;Value: a

1 ]=> (eval (list 'or 'a 'false) 'env)
;Value: a

1 ]=> (eval (list 'or 'false 'b) 'env)
;Value: b

1 ]=> (eval (list 'or 'false 'false) 'env)
;Value: false


1 ]=> (eval (list 'and 'a 'b) 'env)
;Value: b

1 ]=> (eval (list 'and 'false 'b) 'env)
;Value: false

1 ]=> (eval (list 'and 'false 'false) 'env)
;Value: false

1 ]=> (eval (list 'and 'a 'false) 'env)
;Value: false


