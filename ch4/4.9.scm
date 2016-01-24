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
; if the condition is not false, evaluates the body and calls itself recursively

; There are some challenges with this, though. In order to call itself recursively,
; the procedure needs a name in the language that we're interpreting, which means
; if we give it an arbitrary name it could conflict with other user-specifed names.
; But let's start there, just to get our feet under us

(define (while->if exp)
  (define (while-condition exp)
    (cadr exp))
  (define (while-body)
    (cddr exp))
  (make-if (while-condition exp)
    (make-begin
      (list
        (while-body exp)
        (while->if exp)))
    'done))  ; iteration construct has no return value