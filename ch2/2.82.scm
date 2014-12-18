; Show how to generalize apply-generic to handle coercion in the general case of multiple arguments. One strategy is to attempt to 
; coerce all the arguments to the type of the first argument, then to the type of the second argument, and so on. Given an example of 
; a situation where this strategy (and likewise the two argument version given above) is not sufficiently general. (Hint: Consider the
; case where there are some suitable mixed-type operations present in the table that will not be tried.)
; =====
; Let's start with the last part since that helps clarify what we're trying to accomplish. The two argument strategy and the one 
; we give is not suitably general for finding coercions that are more than one hop away. Suppose we have an integer to rational
; number coercion and a rational number to complex number coercion. Given an operation on a comple number and an integer, we 
; won't find an integer to complex number coercion and we won't figure out that if we first convert the integer to a rational
; number we can then convert it to a complex number. (We'll get to this in the next exercise.)
;
; Also, we could run into situations where the arguments could convert to more than one type in the argument list but the operation
; is not defined for all of those types. In this case, even though the operation could be performed if converted to one type, there's
; no guarantee that it will be converted to that type.
;
; With that scope in place, let's update apply-generic. The idea is to go through the arguments and find the first type that
; we can convert all the other types to.
;
; We'll do that with the help of a couple abstract procedures. We use every to see if each element of a list satisfies a condition
; and some to see if at least one element of a list satisfies a condition (and return that element). We just look for some 
; argument whose type every other argument can be coerced to.
(define (apply-generic op . args)
  (define (every test elements)
    (cond
      ((null? elements) true)
      ((test (car elements)) (every test (cdr elements)))
      (else false)))
  (define (some test elements)
    (cond 
      ((null? elements) false)
      ((test (car elements)) (car elements))
      (else (some test (cdr elements)))))
  (define (find-coercion-type types) ; find first type where every other type converts to it
    (some 
      (lambda (target)
        (every 
          (lambda (test) 
            (or 
              (eq? test target) 
              (get-coercion test target))) ; either same type or coercion procedure exists
          types))
      types))
  (define (convert-args-to-type target-type args)
    (map 
      (lambda (a)
        (if (eq? (type-tag a) target-type)
          a
          ((get-coercion (type-tag a) target-type) a))) ; get and perform coercion
      args))
  (define (lookup-error op tags)
    (error "No method for these types" (list op tags)))
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
        (apply proc (map contents args))
        (if (some ; not already all the same type
              (lambda (t) (not (eq? t (car type-tags))))
              type-tags) 
          (let ((target-type (find-coercion-type type-tags)))
            (if target-type  
              (apply ;if we have a target type, map all args to this type and call apply-generic again
                apply-generic 
                (cons op (convert-args-to-type target-type args)))
              (lookup-error op type-tags)))
          (lookup-error op type-tags))))))



;; These work with either type in front
1 ]=> (add 5 (make-rational 8 3))
rational
;Value 41: (rational 23 3)

1 ]=> (add (make-rational 8 3) 5)
rational
;Value 43: (rational 23 3)

; We don't have any procs in the table that work on multiple arguments, so let's just define a simple one and have it work on 
; three complex args. Note that here we're handling coercion of multiple args, but not lookup by arbitrary number of args:
(put 'display-nums '(rational rational rational)
	(lambda (a b c) 
		(display a)
		(display b)
		(display c)))

(define (display-nums a b c)
	(apply-generic 'display-nums a b c))

; And here you can see that we coerce scheme-numbers to rational numbers, whatever position they are in
1 ]=> (display-nums (make-rational 1 2) 3 4)
(1 2)(3 1)(4 1)

1 ]=> (display-nums 1 (make-rational 2 3) 4)
(1 1)(2 3)(4 1)

1 ]=> (display-nums 1 2 (make-rational 3 4))
(1 1)(2 1)(3 4)

1 ]=> (display-nums (make-rational 8 9) 2 (make-rational 3 4))
(8 9)(2 1)(3 4)


