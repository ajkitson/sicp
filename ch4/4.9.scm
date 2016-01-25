; Many languages support a variety of language constructs, such as do, for,
; while, and until. In Scheme, iterative processes can be expressed in terms of
; ordinary procedure calls, so special iteration constructs provide no essential
; gain in computational power. On the other hand, such constructs are often
; convenient. Design some iteration constructs, give examples of their use, and
; show how to implement them as derived expressions
; ==========
; We'll do while and for loops. While just takes a stop condition and a block
; of code to execute until that stop condition is true. We can represent
; it as ('while <continue condition> <body>). We will have it evaluate to the
; value of its body on the last iteration (or false if no iterations)

; Here's an example use of while:
(let ((a 1))
  (while (< a 10)
    (display "a: ")
    (display a)
    (newline)
    (set! a (+ a 1))))

; This is equivalent to:
(let ((a 1))
  (define (loop)
    (if (< a 10)
      (begin
        (display "a: ")
        (display a)
        (newline)
        (set! a (+ a 1))
        (loop))
      'done))
  (loop))

; Because we need to return a single derived expression, we'll wrap the definition
; of loop and its first invocation in a begin:
(let ((a 1))
  (begin
    ; define our loop
    (define (loop)
      (if (< a 10) ; while-condition
        (begin
          ; start while-body
          (display "a: ")
          (display a)
          (newline)
          (set! a (+ a 1))
          ; end while-body
          (loop))
        'done))
    ; enter our loop
    (loop)))

; We can define our while loop as a procedure that evaluates the condition, and
; if the condition is not false, evaluates the body and calls itself recursively:
(define (while->derived exp)
  (define (while-condition exp) (cadr exp))
  (define (while-body exp) (cddr exp))
  (make-begin (list
    ; 1. define our loop
    (make-define '(loop) (list
      (make-if (while-condition exp)
        (make-begin (list
          (make-begin (while-body exp))
          '(loop))) ; recursively call our loop
        "done")))
    ; 2. enter our loop
    '(loop))))

; There are a number of begins above. We need to wrap the procedure definition and
; its first invocation in a begin because there is one expression we need to return.
; And our if needs one expression in the consequent but also needs to evaluated
; the body and call itslef recursively. And the body likely has multiple expressions,
; so we wrap those in a begin.

; There are some challenges with the above. Namely that if 'loop is already defined,
; our implementation will interfere with that definition since we're creating a
; procedure in the language we're evaluating.

; Is there a way around this? Our options are:
; - use recursion without naming to do the looping
; - do not use recursion to do the looping
; - do not use a derived expression to do looping
; - use a name we know will not confict (e.g. a dynamically constructed one)
;
; There is a way to do recursion without a named procedure:
((lambda (f) (f f))
  (lambda (recursive-f)
    (lambda (n)
      (if (< n 1)
        'done
        (begin
          (display n)
          (newline)
          ((recursive-f recursive-f) (- n 1)))))))

; Prints this when evaluated:
;(((lambda (f) (f f))
;  (lambda (recursive-f)
;    (lambda (n)
;      (if (< n 1)
;        'done
;        (begin
;          (display n)
;          (newline)
;          ((recursive-f recursive-f) (- n 1))))))) 5)
;5
;4
;3
;2
;1

; But this doesn't get around our problem since, in this case, we still need to
; introduce a parameter name to refer to our lambda, and that could mask the same
; name used elsewhere...
;
; Since recursion is our iteration method (after all, we're in the process of
; making the while loop) and because we're tasked with making a derived expression,
; we'll rule out the other options. So we'll stick with 'loop.

; Alright, now that we've got our while loop, until and do are easy. until is just
; like while, but we loop as long as the condition is false:
(define (until? exp) (tagged-list? exp 'until))
(define (until->derived exp)
  (define (until-condition exp) (cadr exp))
  (define (until-body exp) (cddr exp))
  (while->derived (cons 'while (cons
    (list 'not (until-condition exp)) ; wrap the condition in a not
    (until-body exp)))))

; Here we just change the condition to return the opposite of what it normally
; would and then define until in terms of while. We could also have copied the
; while definition and switched the consequent and alternative clauses.

; Do is just like while, except we'll always run the body at least once. This is
; a "do while" version of do. It's just like while, except we only check the
; condition when deciding whether to recurse:
(define (do? exp) (tagged-list? exp 'do))
(define (do->derived exp)
  (define (do-condition exp) (cadr exp))
  (define (do-body exp) (cddr exp))
  (make-begin (list
    ; 1. define our loop
    (make-define '(loop) (list
      (make-begin (do-body exp))
      (make-if (do-condition exp)
        '(loop) ; recursively call our loop
        "done")))
    ; 2. enter our loop
    '(loop))))

