; Let expressions ar derived expressions, because

; (let ((<var1> <exp1>) (<var2> <exp2>)... (<varn> <expn>))
;   <body>)

; is equivalent to

; ((lambda (<var1> .... <varn>)
;   <body>)
; <exp1>
; ...
; <expn>)

; Implement a syntactic transformation let->combination that reduce evaluating
; let expression to evaluating combinations of the type shown above, and add the
; appropriate clause to eval to handle let expressions.
; ==================================
; To convert to a lambda, we just grab the variables fromt the let bindings
; and make them our lambda parameters, then pass in the values for the let
; bindings as the arguments to the lambda expression.
;
; Since we represent procedure application as a list with the operator as the
; car and operands as the cdr, we can just convert the let to an application
; with a lambda in the operator position and the binding values in the operands
; position

(define (let? exp) (tagged-list? exp 'let))
(define (let-bindings exp) (cadr exp))
(define (let-body exp) (cddr exp))
(define (let->lambda exp)
  (cons   ; use cons so args are not nested: ((lambda (param1 param2) body1 body2) arg1 arg2)
    (make-lambda
      (map car (let-bindings exp))
      (let-body exp))
    (map cadr (let-bindings exp))))

; Here's what it looks like in our evaluator:
;;; M-Eval input: (let ((a 1)) (+ a a))
;;; M-Eval value: 2
;;; M-Eval input: (let ((a 1)(b 2)) (+ a b))
;;; M-Eval value: 3