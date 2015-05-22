; Rewrite eval so that the dispatch is done in data-directed style. Compare
; this with the data-directed differentiation procedure of exercise 2.73.
; (You may use the car of a compound expression as the type of the expression,
; as is appropriate for the syntax implemented in this section.)
; ========
; Alrighty. Let's recall the building blocks of a data-directed system:
; - data is tagged
; - the tag on a data determines the procedure we use to operate on it
; - procedures are registered centrally and looked up by their tag
;
; We're already a good part of the way to a data-directed system, since the
; expressions are all tagged with their type. Except, of course, the
; non-compound expressions. For those, we'll need special checks. Also, if
; we're not tagging procedure application like Louis wanted in 3.1 (and I
; don't think we should), we can't just default to the procedure in the table
; lookup. Intead, we'll have to check the table for a procedure and apply it
; if we find one, but if not, do the application? check. Also, we're stripping
; the tag before passing it along to the handling code.
;
; Here's our data-directed eval:
(define (eval exp env)
    (cond
        ((self-evaluating? exp) exp)
        ((variable? exp) exp)
        (else (let ((eval-proc (get (operator exp) 'eval)))
            (cond (eval-proc
                    ; (display (eq? eval-proc eval-if))
                    (eval-proc (operands exp) env))
                  ((application? exp)
                    (apply (eval (operator exp) env)
                           (list-of-values (operands exp) env)))
                  (else (error "Unknown expression type -- EVAL" (list exp env))))))))

; Our supporting code is below. It comes from 4.1 and 4.2 (for the eval pieces)
; and 3.25 for the table to use to store the procedures. We haven't built out
; the table yet (will do that in a second), but this is enough to allow us to
; do the simple procedure applications we did in 4.2:

1 ]=> (eval (list + 1 2 3) 'env)
;Value: 6
1 ]=> (eval (list list 1 2 3) 'env)
;Value 2: (1 2 3)

; I'm using list here because the expression is supposed to be a list. If I try
; to pass the expression itself as a parameter mit-scheme (the interpreter our
; interpreter is running in) evaluates it before we can do anything with it.
;
; Now we can update the table to handle evaluating some other stuff. We'll do
; if since it doesn't depend on the environment for evaluation (SICP hasn't yet
; elucidated how the environment figures into the evaluation).
(define (eval-if exp env)
    (define (if-predicate exp) (car exp))
    (define (if-consequent exp) (cadr exp))
    (define (if-alternative exp)
        (if (not (null? (cddr exp)))
            (caddr exp)
            'false))
    (if (true? (eval (if-predicate exp) env))
        (eval (if-consequent exp) env)
        (eval (if-alternative exp) env)))
(put 'if 'eval eval-if)

; And here we go! Even works with nested values:
1 ]=> (eval (list 'if 'false (list + 1 2) (list 'if 'true (list + 3 4) (list + 5 6))) 'env)

; And our supporting code:
;; Predicates
(define (self-evaluating? exp)
    (cond
        ((number? exp) true)
        ((string? exp) true)
        ((procedure? exp) true)
        (else false)))
(define (variable? exp) (symbol? exp))
(define (application? exp) (pair? exp))
(define (no-operands? exp) (null? exp))

;; Selectors
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

;; Transforms
(define (list-of-values exps env)  ; Left-to-right eval from ex 4.1
    (if (no-operands? exps)
        '()
        (let ((results (list 'temp 'temp)))
            (set-car! results (eval (first-operand exps) env))
            (set-cdr! results (list-of-values (rest-operands exps) env))
            results)))



; And here, finally, are our general data-directed support functions. We'll
; use our arbitrary key table from ex 3.25 and define get and put procedures
; that work on an instance of it:

(define (make-table same-key?)
    (define (assoc key records)
        (cond ((null? records) false)
              ((same-key? (caar records) key) (car records))
              (else (assoc key (cdr records)))))
    (define (add-to-table! record table)
        (set-cdr! (cdr table) (cons record (cddr table))))

    (define (is-table? t)
        (if (not (pair? t))
            false
            (eq? (car t) '*table-struct*)))

    (define (lookup keys table)
        (let ((entry (assoc (car keys) (cddr table))))  ; switch subtable to entry since it could be a table or record
            (if entry
                (if (null? (cdr keys)) ; no more keys
                    (cdr entry)
                    (if (is-table? (cdr entry))
                        (lookup (cdr keys) entry)
                        false))
                false)))

    (define (insert! keys value table)
        (let ((entry (lookup (list (car keys)) table))) ; look up entry next level down
            (if entry
                (if (null? (cdr keys))
                    (set-cdr! entry value)            ; update entry  using car keys and value
                    (insert! (cdr keys) value entry)) ; entry is a table, so insert into that with remaining keys
                (if (null? (cdr keys))
                    (add-to-table! (cons (car keys) value) table) ; add new value to table
                    (let ((new-table (list (car keys) '*table-struct*)))
                        (add-to-table! new-table table)
                        (insert! (cdr keys) value new-table)))))
        'ok)
    (let ((local-table (list '*table* '*table-struct*)))
        (define (dispatch m)
            (cond ((eq? m 'lookup-proc)
                    (lambda (keys) (lookup keys local-table)))
                  ((eq? m 'insert-proc!)
                    (lambda (keys val) (insert! keys val local-table)))
                  ((eq? m 'show) (display local-table))))
        dispatch))

(define procedure-table (make-table eq?))
(define (get type operation)
    ((procedure-table 'lookup-proc) (list type operation)))
(define (put type operation code)
    ((procedure-table 'insert-proc!) (list type operation) code))




