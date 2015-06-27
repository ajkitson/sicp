(define apply-in-underlying-scheme apply)

;; EVAL
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((quoted? exp) (text-of-quotation exp))
        ((assignment? exp) (eval-assignment exp env))
        ((definition? exp) (eval-definition exp env))
        ((and? exp) (eval-and exp env))
        ((or? exp) (eval-or exp env))
        ((if? exp) (eval-if exp env))
        ((lambda? exp)
          (make-procedure (lambda-parameters exp) (lambda-body exp) env))
        ((begin? exp)
          (eval-sequence (begin-actions exp) env))
        ((cond? exp) (eval (cond->if exp) env))
        ((let? exp) (eval (let->derived exp) env))
        ((let*? exp) (eval (let*->nested-lets exp) env))
        ((application? exp)
          (apply-new (eval (operator exp) env)
                 (list-of-values (operands exp) env)))
        (else
          (error "Unknown expression type -- EVAL" exp))))

;; APPLY
(define (apply-new procedure arguments)
  (cond ((primitive-procedure? procedure)
          (apply-primitave-procedure procedure arguments))
        ((compound-procedure? procedure)
          (eval-sequence
            (procedure-body procedure)
            (extend-environment
              (procedure-parameters procedure)
              arguments
              (procedure-environment procedure))))
        (else (error "Unknown procedure type -- APPLY-NEW" procedure))))

;; Procedure Functions
(define (list-of-values exp env)
  (if (no-operands? exp)
    '()
    (cons (eval (first-operand exp) env)
          (list-of-values (rest-operands exp) env))))

;; Conditionals
(define (eval-if exp env)
  (if (true? (eval (if-predicate exp) env))
    (eval (if-consequent exp) env)
    (eval (if-alternative exp) env)))

;; Sequences
(define (eval-sequence exps env)
  (cond ((last-exp? exps) (eval (first-exp exps) env))
        (else (eval (first-exp exps) env)
               (eval-sequence (rest-exps exps) env))))

;; Assignment and Definition
(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
                       (eval (assignment-value exp) env)
                       env)
  'ok)

(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
                    (eval (definition-value exp) env)
                    env)
  'ok)

;; Expression Predicates
(define (self-evaluating? exp)
  (cond ((number? exp) true)
        ((string? exp) true)
        ((boolean? exp) true) ; not in book, but needed for now...
        (else false)))

(define (variable? exp) (symbol? exp))

(define (quoted? exp)
  (tagged-list? exp 'quote))

(define (text-of-quotation exp) (cadr exp))

(define (tagged-list? exp tag)
  (if (pair? exp)
    (eq? (car exp) tag)
    false))

(define (assignment? exp)
  (tagged-list? exp 'set!))
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

(define (definition? exp)
  (tagged-list? exp 'define))

(define (definition-variable exp)
  (if (symbol? (cadr exp))
    (cadr exp)    ; (define var exp)
    (caadr exp))) ; (define (proc a1 a1) body)

(define (definition-value exp)
  (if (symbol? (cadr exp))
    (caddr exp)
    (make-lambda (cdadr exp)   ; parameters
                 (cddr exp)))) ; body

(define (make-define var value)
  (cons 'define (cons var value)))

(define (lambda? exp) (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body))) ; '(lambda (parameters...) exp1 exp2...)

(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
  (if (not (null? exp))
    (cadddr exp)
    'false))
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))

(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq))
        (else (make-begin seq))))

(define (make-begin seq) (cons 'begin seq))


(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

; Derived Expressions
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))

(define (cond-map? clause)
  (eq? (cadr clause) '=>))
(define (cond-map-procedure clause)
  (caddr clause)) ; grab 3rd elem in clause

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

; Let
(define (let? exp) (tagged-list? exp 'let))
; (define (let-bindings exp) (cadr exp))
; (define (let-body exp) (cddr exp))
(define (named-let? exp)
(not (pair? (cadr exp))))

(define (let-bindings exp)
  (if (named-let? exp)
    (caddr exp)
    (cadr exp)))
(define (let-body exp)
  (if (named-let? exp)
    (cdddr exp)
    (cddr exp)))

(define (let->derived exp)
  (if (named-let? exp)
    (let->combination exp)
    (let->lambda exp)))

(define (let->lambda exp)
  (cons   ; use cons so args are not nested: ((lambda (param1 param2) body1 body2) arg1 arg2)
    (make-lambda
      (map car (let-bindings exp))
      (let-body exp))
    (map cadr (let-bindings exp))))


(define (let*? exp) (tagged-list? exp 'let*))
(define (make-let bindings body)
  (cons 'let (cons bindings body))) ;('let (param1 param2) exp1 exp2)

(define (let*->nested-lets exp)
  (make-let
    (list (car (let-bindings exp)))
    (if (null? (cdr (let-bindings exp)))
      (let-body exp)
      (list (let*->nested-lets
        (cons 'let*
              (cons (cdr (let-bindings exp))
                    (let-body exp))))))))


(define (let->combination exp)
  (define (parameters exp)
    (map car (let-bindings exp)))
  (define (initial-argurments exp)
    (map cadr (let-bindings exp)))
  (let ((proc-name (cadr exp)))
    (make-begin
      (list  ; define procedure for named let and then call that procedure
        (make-define
          (cons proc-name (parameters exp))  ; (procname p1 p2 p3)
          (let-body exp))
        (cons proc-name (initial-argurments exp))))))

;; Testing Predicates
(define (true? val) (not (false? val)))
(define (false? val) (eq? val false))

;; Operators
(define (and? exp) (tagged-list? exp 'and))
(define (eval-and exp env)
  (define (expand-and exp)
    (let ((first (eval (car exp) env)))
      (if (not (true? first))
        (eval 'false env)
        (if (null? (cdr exp))
          first
          (expand-and (cdr exp))))))
  (if (null? (cdr exp))
    (eval 'true env)   ; no expressions => true
    (expand-and (cdr exp))))


(define (or? exp) (tagged-list? exp 'or))
(define (eval-or exp env)
  (define (expand-or exp)
    (if (null? exp)
      (eval 'false env)
      (let ((first (eval (car exp) env)))
        (if (true? first)
          first
          (expand-or (cdr exp))))))
  (expand-or (cdr exp)))

;; Evaluator Data Structures
(define (make-procedure parameters body env)
  (list 'procedure parameters body env))
(define (compound-procedure? p) (tagged-list? p 'procedure))
(define (procedure-parameters p) (cadr p))
(define (procedure-body p) (caddr p))
(define (procedure-environment p) (cadddr p))

; Environment Procedures
(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define the-empty-environment '())

(define (make-frame variables values)
  (cons variables values))
(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))
(define (add-binding-to-frame! var val frame)
  (set-car! frame (cons var (car frame)))
  (set-cdr! frame (cons val (cdr frame))))

(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
    (cons (make-frame vars vals) base-env)
    (if (< (length vars) (length vals))
        (error "Too many arguments supplied" vars vals)
        (error "Too few arguments supplied" vars vals))))

(define (lookup-variable-value var base-env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
              (env-loop (enclosing-environment env)))
            ((eq? var (car vars)) (car vals))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable -- LOOKUP" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop base-env))

(define (set-variable-value! var val env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
              (env-loop (enclosing-environment env)))
            ((eq? (car vars) var) (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
      (error "Unbound variable -- SET!" var)
      (let ((frame (first-frame env)))
        (scan (frame-variables frame)
              (frame-values frame)))))
  (env-loop env))

(define (define-variable! var val env)
  (let ((frame (first-frame env)))
    (define (scan vars vals)
      (cond ((null? vars)
              (add-binding-to-frame! var val frame))
            ((eq? var (car vars))
              (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (scan (frame-variables frame)
          (frame-values frame))))


;; Environment Setup
(define primitive-procedures
  (list (list 'car car)
        (list 'cdr cdr)
        (list 'cons cons)
        (list 'list list)
        (list 'null? null?)
        (list '= =)
        (list '< <)
        (list '> >)
        (list '+ +)
        (list '- -)
        (list 'symbol? symbol?)
        ; ... we can add more
        ))
(define (primitive-procedure-names)
  (map car primitive-procedures))
(define (primitive-procedure-objects)
  (map
    (lambda (proc) (list 'primitive (cadr proc)))
    primitive-procedures))

(define (setup-environment)
  (let ((initial-env
         (extend-environment
           (primitive-procedure-names)
           (primitive-procedure-objects)
           the-empty-environment)))
    (define-variable! 'true true initial-env)
    (define-variable! 'false false initial-env)
    initial-env))

(define the-global-environment (setup-environment))

(define (primitive-procedure? proc)
  (tagged-list? proc 'primitive))
(define (primitive-implementation proc) (cadr proc))

(define (apply-primitave-procedure proc args)
  (apply-in-underlying-scheme (primitive-implementation proc) args))

(define input-prompt ";;; M-Eval input: ")
(define output-prompt ";;; M-Eval value: ")

(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output (eval input the-global-environment)))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))

(define (prompt-for-input string)
  (newline) (display string))
(define (announce-output string)
  (display string))
(define (user-print object)
  (if (compound-procedure? object)
    (display (list 'compound-procedure
                   (procedure-parameters object)
                   (procedure-body object)
                   '<procedure-env>))
    (display object)))

(define evaluator driver-loop)
