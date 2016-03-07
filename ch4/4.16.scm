; In this exercise we implement the method just described for interpreting
; internal definitions. We assume that the evaluator supports let (see exercise
; 4.6).
;
; a. Change lookup-variable-value (section 4.1.3) to signal an error if the value
;   it finds is the symbol *unassigned*
;
; b. Write a procedure scan-out-defines that takes a procedure body and returns
;   an equivalent one that has no internal definitions, by making the
;   transformation described above.
;
; c. Install scan-out-defines in the interpreter, either in make-procedure or in
;   procedure-body (see section 4.1.3). Which place is better? Why?
; ================
; Alright, here's the new lookup-variable-value:
(define (lookup-variable-value var base-env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond
        ((null? vars)
          (env-loop (enclosing-environment env)))
        ((eq? var (car vars))
          (if (eq? (car vals) '*unassigned*)
            (error "Variable accessed before it has been defined" var)
            (car vals)))
        (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable -- LOOKUP" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop base-env))

; And now we can do the transformation. We will filter the statements in the
; body, once to create the list of definitions and again to create the body
; withoud definitions, then transform the definitions into lets followed by sets.
(define (scan-out-defines body)
  (let ; split out define statements and the non-definition statements
    ((define-statements (filter definition? body))
     (body-statements (filter (lambda (s) (not (definition? s))) body)))

     (show "define-statements" define-statements)
     (show "body-statements" body-statements)

     (if (null? define-statements)
       body ; if there are no define-statements, just use the original body

       (let ; get the definition variables and expressions
        ((variables (map definition-variable define-statements))
         (expressions (map definition-value define-statements)))
         (let ((
           ret (make-let
             (map (lambda (v) (list v '*unassigned*)) variables) ; bindings
               (append ; body: set!s for variable assignment and then the rest of the body
                 (map (lambda (s) (cons 'set! s)) (zip variables expressions))
                 body-statements))))
                 (show "scanned out" ret)
                 (list ret))) ; receives a list of expressions, and so must return a list of expressions
           )))

; And finally we'll install this in make-procedure. Why make-procedure instead
; of procedure body? Because we don't want to run this more often than necessary.
; If it were to be in procedure-body, we would run it every time the procedure were
; evaluated, whereas in make-procedure we do scan-out-defines only once, upon
; definition. This means we might run it when we don't need to if the procedure
; is never evaluated, but for recursive procedures or others that get evaluated
; more than once it makes sense to do it on definition.

(define (make-procedure parameters body env)
  (list 'procedure parameters (scan-out-defines body) env))

