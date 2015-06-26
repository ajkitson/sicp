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

(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))

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
1 ]=> (eval (cond->if (list 'cond (list 'false 1)(list 'true 2)(list 'else 3))) the-global-environment)
;Value: 2

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

; Let's note a couple things here. First, we don't want to evaluate the
; predicate more than once. That would be inefficient, and what if evaluating
; the predicate mutates data? That removes the obvious solution:

(make-if (cond-predicate first)
         (list (cond-map-procedure first) (cond-predicate first))
         (expand-clauses rest))

; Second, we represent procedure application as a compound expression that
; is not one of the special forms or derived expressions that the evaluator
; is looking for. It is a two element list, the first element being the
; operator and the second being a list of operands.
;
; To get around evaluating the predicate twice, we'll use the technique we
; discussing in exercise 4.4. We'll create a lambda and pass the predicate
; as an argument to the lambda. The predicate will be evaluated once on
; being passed to the lambda. Inside the lambda, we'll have an if that tests
; the predicate and does the right branching bsed on that value.

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
          (list
            (make-lambda
              (list 'predicate-value)
              (list
                (make-if 'predicate-value
                  (list (cond-map-procedure first) 'predicate-value)
                  (expand-clauses rest))))
            (cond-predicate first))
          (make-if (cond-predicate first)
                   (sequence->exp (cond-actions first))
                   (expand-clauses rest)))))))

; And here we go:

;;; M-Eval input: (cond (true 1)((list 2 3) => cdr)(else 4))
;;; M-Eval value: 1
;;; M-Eval input: (cond (false 1)((list 2 3) => cdr)(else 4))
;;; M-Eval value: (3)
;;; M-Eval input: (cond (false 1)(false => cdr)(else 4))
;;; M-Eval value: 4

