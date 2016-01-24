; Let* is similar to let, except that the bindings of the let variables are
; performed sequentially from left to right, and each binding is made in an
; environment in which all of the proceeding bindings are visible. For example

; (let* ((x 3)
;        (y (+ x 2))
;        (z (+ x y 5)))
; (* x z))

; returns 39. Explain how a let* expression can be rewritten as a set of nested
; let expressions, and write a procedure let*->nested-lets that performs this
; transformation. If we have already implemented let (exercise 4.6) and we
; want to extend the evaluator to handle let*, is it sufficient to add a clause
; to eval whose action is

; (eval (let*->nested-lets exp) env)

; or must we explicitly expand let* in terms of non-derived expressions?
; ===============
; let* is equivalent to a set of nested let statements, where the outermost
; let has the first binding and innermost the last binding. This gives each
; binding access to all the previous.
;
; The above example is therefore the same as
; (let ((x 3))
;   (let ((y (+ x 2)))
;     (let ((z (+ x y 5)))
;       (* x z))))
;
; And this is the same as
; ((lambda (x)
;   ((lambda (y)
;     ((lambda (z) (* x z)) (+ x y 5)))
;   (+ x 2)))
; 3)
;
; We already have let->combination that converts let into lambdas. For let* we
; can piece apart the bindings into a set of nested one binding normal lets
; and allow the evaluator to do the let->combination on each.
;
; We'll want a way to identify let* expressions:
(define (let*? exp) (tagged-list? 'let* exp))

;and a way to construct let statements:
(define (make-let bindings body)
  (cons 'let (cons bindings body))) ;('let (param1 param2) exp1 exp2)

; Now we just convert to a set of nested lets:
(define (let*->nested-lets exp)
  (make-let
    (list (car (let-bindings exp)))
    (if (null? (cdr (let-bindings exp)))
      (let-body exp)
      (list    ; do a list b/c the converted let is just the first expression in the body
        (let*->nested-lets
          (cons 'let*  ; must reappend the tag so binding and body are in correct position
            (cons
              (cdr (let-bindings exp))
              (let-body exp))))))))

; And in action:
;;; M-Eval input: (let* ((a 1) (b (+ a 1))) (+ a b))
;;; M-Eval value: 3


; Regarding the second part of the question, is it sufficient to just put the
; following in eval to handle let*?
; (eval (let*->nested-lets exp) env)

; It is. Each let extends the environment of those nested within it. At first,
; I thought this might require separate calls to eval with a new environment each
; time. But it doesn't. Or rather, if it does, it will require that same work
; whehter we convert let* to a set of nested lets or whether we write out
; the nested lets in the first place. Since the evaluator will have to handle
; the explicitly nested lets, there is no need to do anything special for let*
; if we can convert let* expressions to the equivalent nested let expressions,
; and we can.



