; Define a generic predicate =zero? that tests if its argument is zero, and install it in all the arithmetic packages. This operation
; should work for ordinary numbers, rational numbers, and complex numbers.
; =====
; Again, we define the =zero? predicate globally, and it defers to apply-generic to figure out what to do given the number type.
; We create a package that'll define =zero? for the different number types. The puts in install-zero-package could be added 
; to the individual arithmetic packages, and that's probably the way to do it for a real system (you wouldn't have to duplicate the
; supporting code), but I'm doing it all here because part of the fun of the data-directed style is that you can define these predicates
; wherever you want. And it makes the exercise shorter.

(define (=zero? x) (apply-generic '=zero? x))

(define (install-zero-package)
	(define (zero? x) (= x 0))
	(define (numer x) (car x))
	(define (magnitude x)
		(apply-generic 'magnitude x))


	(put '=zero? '(scheme-number) zero?)
	(put '=zero? '(rational)
		(lambda (x) (zero? (numer x))))
	(put '=zero? '(complex)
		(lambda (x) (zero? (magnitude x))))
	'done)

1 ]=> (=zero? 1)
;Value: #f
1 ]=> (=zero? 0)
;Value: #t
1 ]=> (=zero? (make-rational 1 2))
1 ]=> (=zero? (make-rational 0 2))
;Value: #t

1 ]=> (=zero? (make-from-real-imag 1 2))
;Value: #f
1 ]=> (=zero? (make-from-real-imag 0 2))
;Value: #f
1 ]=> (=zero? (make-from-real-imag 0 0))
;Value: #t
