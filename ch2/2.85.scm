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

; (Also, it's not clear to me why the 1.5 + 0i example can't convert to the rational number 3/2. Mathematically, it works, right?
; Anyway, we'll use round as they suggest in the first pass and might add support for this later. You would just have to multiply
; by 10 until you have no decimals, use that as the numerator and 10^(number of times you multiplied) for the denom and make- rational
; will simplify it)


; Here's drop:
(define (drop n)
	(let ((lower-n (project n)))
		(if (not (equ? n (raise lower-n))) 
			n
			(drop lower-n))))

; Now let's get project set up. First defer to apply-generic:
(define (project n)
	(apply-generic 'project n))

; Now define procedures for different number types:
(define (install-project)
	(put 'project '(complex)
		(lambda (n) (make-real (real-part n)))) ; complex->real: drop imaginary part

	(put 'project '(real)
		(lambda (n) (make-rational (round n) 1)))  ; real->rational: just round n and put over 1 (what the text suggests)

	(put 'project '(rational)
		(lambda (n) (round (/ (numer n) (denom n))))) ; rational->integer: divide numer and denom and round
	(put 'project '(complex)
		(lambda (n) ())))

; Lastly, we simply wrap the apply-generic return value in drop
(define (apply-generic op . args)
	(define (lookup-error op tags)
		(error "No method for these types" (list op tags)))
	(let ((type-tags (map type-tag args)))
		(let ((proc (get op type-tags)))
			(if proc
				(drop (apply proc (map contents args)))  ; wrap in drop -- only real exit point
				(if (= (count-uniques type-tags) 1) ; if already same type, don't coerce
					(lookup-error op type-tags)
					(let ((coerce-to (highest-type type-tags)))
						(apply 
							apply-generic 
							(cons op (map (lambda (a) (raise-until a coerce-to)) args)))))))))






