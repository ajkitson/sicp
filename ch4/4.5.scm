; Scheme allows an additional syntax for cond clauses, (<test> => <recipient>).
; If <test> evaluates to a true value, then <recipient> is evaluated. Its value
; must be a procedure of one argument; this procedure is then invoked on the
; value of the <test>, and the result is returned as the value of the cond
; expression. For example,

; (cond ((assoc 'b '((a 1) (b 2))) => cadr)
;       (else false))

; returns 2. Modify the handling of cond so that it supports this extended
; syntax.
; ======
; Important to note: this is a clause-level syntax. You can mix and match
; clauses with the normal syntax and those that use the => symbol within the
; same cond expression.
;
; So what do we need here? A way to tell what type of clause we're dealing
; with and that will handle the values appropriately for => clauses (that is,
; will hang onto the predicate value and pass it to the procedure in the
; consequent).
;
; Here's the current implementation of cond:

(define (cond-clauses exp) (cdr exp))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
  (if (null? clauses)
    'false
    (let ((first (car clauses))
          (rest (cdr clauses)))
      (if (cond-else-clause? first)
        (if (null? rest)
          (sequence->exp (cond-actions first))
          (error "ELSE clause isn't last -- COND->IF" clauses))
        (make-if (cond-predicate first)
                 (sequence->exp (cond-actions first))
                 (expand-clauses rest))))))

; With some supporting code
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq))
        (else (make-begin seq))))
(define (make-begin seq) (cons 'begin seq))

; Here we can see it in action:
1 ]=> (eval (cond->if (list 'cond (list 'false 'a)(list 'true 'b)(list 'else 'c))) 'env)
;Value: b

; So how do we insert our mapping cond clauses? We should be able to check
; the clause and see if it's a mapping (=>) clause, and if so, handle it a bit
; specially. First we'll have a check to see what type of clause it is:
(define (cond-map? clause)
  (eq? (cadr clause) '=>))

; And another to grab the procedure if it's the type of cond that maps the
; predicate result
(define (cond-map-procedure clause) (caddr clause)) ; grab 3rd elem in clause

; Now we can test for this type of clause in expand-clauses:
(define (expand-clauses clauses)
  (if (null? clauses)
    'false
    (let ((first (car clauses))
          (rest (cdr clauses)))
      (if (cond-else-clause? first)
        (if (null? rest)
          (sequence->exp (cond-actions first))
          (error "ELSE clause isn't last -- COND->IF" clauses))
        (if (cond-map? first)
          ;;
          ;; What do we do here?
          ;;
          (make-if (cond-predicate first)
                   (sequence->exp (cond-actions first))
                   (expand-clauses rest)))))))

; OK, now we're identifying our => clauses. But what do we do with them? We need
; a way to communicate the result of evaluating the predicate to the procedure
; in the consequent. We'll do this by wrapping make-if in a let statement and
; introduce a variable that both the predicate and consequent have access to.
; The predicate will set it and the consequent will use it as its argument.
; We'll wrap both predicate and consequent in lambdas since we want to delay
; evaluating them until the if statements are evaluated, not in constructing
; the if statement to begin with. Also, we only want to evaluate the predicate
; once!
;
; However, we haven't implemented a representation for lambdas yet, so we'll
; mock that out in eval. Nothing too complicated. Just wrap lambdas in list
; so they look like other expressions our eval handles. Then have procedures
; be self-evaluating so that eval resolves the operator of the lambda expression
; to itself and then applies it. (We'll probably have to reverse these changes
; to eval later, as we build it out.)

(define (expand-clauses clauses)
  (if (null? clauses)
    'false
    (let ((first (car clauses))
          (rest (cdr clauses)))
      (if (cond-else-clause? first)
        (if (null? rest)
          (sequence->exp (cond-actions first))
          (error "ELSE clause isn't last -- COND->IF" clauses))
        (if (cond-map? first)
          (let ((predicate-value false))
            (make-if
              (list (lambda () ; gets passed to eval, which is expecting a list
                      (set! predicate-value (cond-predicate first))
                        predicate-value))
              (list (lambda ()
                      ((cond-map-procedure first) predicate-value)))
              (expand-clauses rest)))
          (make-if (cond-predicate first)
                   (sequence->exp (cond-actions first))
                   (expand-clauses rest)))))))


(put 'cond 'eval (lambda (exp env)
  (eval (cond->if exp) env)))

; And it works!
1 ]=> (eval (cond->if (list 'cond (list 'true 'a)(list '(hello goodbye) '=> car)(list 'else 'c))) 'env)
;Value: a

1 ]=> (eval (cond->if (list 'cond (list 'false 'a)(list '(hello goodbye) '=> car)(list 'else 'c))) 'env)
;Value: hello

1 ]=> (eval (cond->if (list 'cond (list 'false 'a)(list 'false '=> car)(list 'else 'c))) 'env)
;Value: c



