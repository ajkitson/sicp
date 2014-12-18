; This section mentioned a method for "simplifying" a data object by lowering it in the tower of types as far as possible. Design a 
; procedure drop that accomplishes this for the tower described in exercise 2.83. The key is to decide, in some general way, whether
; an object can be lowered. For example, the complex number 1.5 + 0i can be lowered as far as real, the complex number 1 + 0i can
; be lowered as far as integer, and the complex numbe 2 + 3i cannot be lowered at all. Here is a plan for determining whether an object 
; can be lowered: Begin by defining a generic operation project that "pushes" an object down in the tower. For example, projecting a
; complex number would involve throwing away the imaginary part. Then a number can be dropped if, when we project it and raise the 
; result back to the type we started with, we end up with something equal to what we stated with. Show how to implement this idea in
; detail, but writing a drop procedure that drops an object as far as possible. You will need to design the various  projection 
; operations and install project as a generic operation in the system. You will also need to make use of a generic equality predicate,
; such as described in 2.79. Finally, use drop to rewrite apply-generic from exercise 2.84 so that it "simplifies" its answers.
; =====
; The plan they proposed sounds good. So drop will repeatedly call project until raising the result of project no longer matches 
; the original value. Then we just need to register a set of project operations, like we did the raise operations. Then we
; simply wrap the apply-generic return value in drop. Oh, and we'll simply use equ? from 2.79 in drop. 
;
; The tricky part is telling when we can't drop any further. The method that follows our current scheme is to not have a project
; procedure for scheme-number. If we try to look one up, we get an error. But when given a scheme number we want to tell that
; we can't lower it without running into the error. What to do? We'll just do like we did with raise and reference the tower to see
; if we can drop further


; From 2.84:
(define tower (list 'scheme-number 'rational 'complex))
(define (position x seq) ; zero-indexed
  (define (pos-iter seq ix)
    (cond
      ((null? seq) -1)
      ((equal? x (car seq)) ix)
      (else (pos-iter (cdr seq) (+ ix 1)))))
  (pos-iter seq 0))
(define (before a b seq)  ; return false if elements not in list at all
  (let ((pos-a (position a seq))
     (pos-b (position b seq)))
    (and 
      (not (= pos-a -1)) ; a is in the list
      (< pos-a pos-b)))) ; and a comes before b


; Using these, we can define drop:
(define (drop n)
	(if (or (= -1 (position (type-tag n) tower)) 
			(eq? (type-tag n) (car tower)))  ; our type is lowest in the tower (or not in the tower) -> can't be dropped further
		n
		(let ((lower-n (project n)))
			(if (equ? n (raise lower-n)) ; drop further if we don't lose precision, otherwise stop with n
				(drop lower-n)
				n))))

; Now let's get project set up. First defer to apply-generic:
(define (project n)
	(apply-generic 'project n))

; Now define procedures for different number types:
; see arithmetic.scm for how we actually added these to the individual arithmetic packages since the types need their specific 
; selectors
(define (install-project)
	(put 'project '(complex)
		(lambda (n) (make-real (real-part n)))) ; complex->real: drop imaginary part

	(put 'project '(real)
		(lambda (n) (make-rational (round n) 1)))  ; real->rational: just round n and put over 1 (what the text suggests)

	(put 'project '(rational)
		(lambda (n) (round (/ (numer n) (denom n))))) ; rational->integer: divide numer and denom and round
	(put 'project '(complex)
		(lambda (n) ())))

; here's drop in action:
; Can't drop
1 ]=> (drop (make-complex-from-real-imag 5 1))
;Value 7: (complex rectangular 5 . 1)

; Complex to int:
1 ]=> (drop (make-complex-from-real-imag 5 0))
;Value: 5

; Rational to int
1 ]=> (drop (make-rational 6 2))
;Value: 3

; Rational that should stay rational
1 ]=> (drop (make-rational 6 4))
;Value 8: (rational 3 2)

; Int stays
1 ]=> (drop 5)
;Value: 5


; Turns out there's another tricky part! As soon as we put drop in apply-generic we risk running into an infinite loop. Because now
; we're not just dropping the final result of our call, but all values returned using apply-generic, including the equ? call
; in drop itself. But really, equ? just returns true or false, so we shouldn't apply drop here. We need to limit drop to 
; numbers. So let's check for a type-tag in drop and quit if it's not in the tower. 
;
; Also, our call to raise runs through drop, which is exactly what we don't want--defeats the whole point of raising. doh!
; How do we drop answers for arithmetic operators and not others? I see two approaches: check in apply-generic against a list
; of operations that shouldn't be dropped, or have the calling function decided whether the result should be dropped, either by
; wrapping the result in drop or passing a flag to apply-generic. 
;
; I'm not wild about either option. I feel best, however, about offering a flag to apply-generic that indicates the result should
; not be dropped. equ? and raise can call apply-generic with that flag. 
;
; Ended up setting it so that if you pass a 'no-drop symbol after the operator, we won't try to drop your result. Chose this because
; if I wrote separate procedures entirely or passed the flag as an arg to apply-generic itself, I'd have to update every call
; to apply-generic and every caller would have to decided whether to drop the result or not. That's more than I want to get itno
; for this little project. 

(define (apply-generic op . args)
  (define (lookup-error op tags)
    (error "No method for these types" (list op tags)))
  (define (apply-generic-internal args)
    (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
        (let ((coerce-to-type (highest-type type-tags)))
          (if (every  ;; every type is already the highest type --> nothing to coerce to!
              (lambda (type) (equal? type coerce-to-type)) 
              type-tags)
            (lookup-error op type-tags)
            (apply ; have to use apply here or args could get nested in one too many lists
              apply-generic
              (cons 
                op 
                (map (lambda (a) (raise-until a coerce-to-type)) args)))))))))
  (if (eq? 'no-drop (car args))
    (apply-generic-internal (cdr args))
    (drop (apply-generic-internal args))))


; And now we've got it working!
; Scheme-number still work:
1 ]=> (mul 10 15)
;Value: 150

; Dropping rationals when we can:
1 ]=> (add (make-rational 3 2) (make-rational 7 2))
;Value: 5

1 ]=> (sub (make-rational 3 2) (make-rational 7 2))
;Value: -2

; And not dropping when we can't:
1 ]=> (mul (make-rational 3 2) (make-rational 7 2))
;Value 38: (rational 21 4)

; Complex number still works:
1 ]=> (add (make-complex-from-real-imag 6 7) (make-complex-from-real-imag 10 20))
;Value 39: (complex rectangular 16 . 27)

; And drops to an int if it can:
1 ]=> (add (make-complex-from-real-imag 6 0) (make-complex-from-real-imag 10 0))
;Value: 16




