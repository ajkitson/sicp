; "Named let" is a varient of let that has the form

; (let <var> <bindings> <body>)

; The <bindings> and <body> are just as in ordinary let, except that <var> is
; bound within <body> to a procedure whose body is <body> and whose parameters
; are the variables in the <bindings>. Thus, one can repeatedly execute the
; <body> by invoking the procedure named <var>. For example, the iterative
; Fibonacci procedure can be rewritten using named let as follows:

(define (fib n)
  (let fib-iter ((a 1)
                 (b 0)
                 (count n))
    (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1)))))

; Modify let->combination of exercise 4.6 to support named let.
; ==========
; The first thing to do is determine whether we have a named let or an
; ordinary let. How can we tell? The best way seems simply to be checking
; whether the first element in the expression is a list of bindings or a
; variable.
(define (named-let? exp)
  (pair? (car exp)))

; Once we know we have a named let, how do we convert it to a combination?
; It's tempting to simply convert it to a set of nested lets, one where we
; take the name and bind it to a normal let statement that contains the inner
; bindings and body, resulting in something like:

(define (fib n)
  (let ((fib-iter
    (let ((a 1)
          (b 0)
          (count n))
      (if (= count 0)
        b
        (fib-iter (+ a b) a (- count 1))))))
  (fib-iter n)))

; But the problem with this is that in binding fib-iter we need to evaluate the
; inner let and that uses fib-iter, which hasn't been bound (becase we're in
; the act of binding it.) Plus (!), if the inner let is not a named let, we
; can't actually call it recursively with new arguments.
;
; So instead, we need to use a nested define to create fib-iter and reproduce
; the named let:

(define (fib n)
  (define (fib-iter a b count)
    (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))
  (fib-iter 1 0 n))

; To do this, we need a procedure to construct a define expression. We already
; have eval-define figure out whether we're defining a variable or a procedure,
; so this can be simple:
(define (make-define var value)
  (cons 'define (cons var value)))

; Now we can create let->combination. We need to modify our helper procedures
; to account for the difference in let forms, with named lets having a variable
; name before the bindings and body. We also need to invoke the newly defined
; procedure in order to create the initial bindings.

(define (let-bindings exp)
  (if (named-let? exp)
    (caddr exp)
    (cadr exp)))
(define (let-body exp)
  (if (named-let? exp)
    (cdddr exp)
    (cddr exp)))

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

; And here it is in action:


;;; M-Eval input: (define (fib n)
  ; (let fib-iter ((a 1)
  ;                (b 0)
  ;                (count n))
  ;   (if (= count 0)
  ;     b
  ;     (fib-iter (+ a b) a (- count 1)))))
;;; M-Eval value: ok
;;; M-Eval input: (fib 5)
;;; M-Eval value: 5
;;; M-Eval input: (fib 6)
;;; M-Eval value: 8

