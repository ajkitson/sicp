; a. Implement this algorithm as a procedure reduce-terms that takes two term lists n and d as arguments and returns a list nn, dd, 
; which are n and d reduced to lowest terms via the algorithm given above. Also write a procedure reduce-poly, analogous to add-poly,
; that checks to see if the two polys have the same variable. If so, reduce-poly strips off the variable and passes the problem
; to reduce-terms, then reattaches the variable to the two term lists supplied by reduce-terms.

; b. Define a procedure analogous to reduce-terms that does what the original make-rat did for integers:

; (define (reduce-integers n d)
; 	(let ((g (gcd n d)))
; 		(list (/ n g) (/ d g))))

; and define reduce as a generic operation that calls apply-generic to dispatch to either reduce-poly (for polynomial arguments)
; or reduce-integers (for scheme-number arguments). You can now easily make the rational-arithmetic package reduce fractions to lowest
; terms by having make-rat call reduce before combining numerator and denominator to form a rational number. The system now handles
; rational expressions in either integers or polynomials. To test your program, try the example at the beginning of this extended
; exercise:

(define p1 (make-polynomial 'x '((1 1) (0 1))))
(define p2 (make-polynomial 'x '((3 1) (0 -1))))
(define p3 (make-polynomial 'x '((1 1))))
(define p4 (make-polynomial 'x '((2 1) (0 -1))))

(define rf1 (make-rational p1 p2))
(define rf2 (make-rational p3 p4))

; (add rf1 rf2)
; ===============
; a. The "algorithm described above" is this: 
; - compute gcd of n and d, 
; - get integerizing factor: (leading coefficient of gcd)^(1 + (max order of n and d) - order of gcd)
; - multiply n and d by integizing factor
; - get gcd of n and d and divide each by this new gcd
;
; Here we go:

  (define (max a b)
    (if (> a b) a b))
 
  (define (reduce-terms n d)
    (let ((g (gcd-terms n d)))
      (let ((factor (expt (coeff (first-term g))
                (+ 1 (- (max (order (first-term n)) (order (first-term d))) 
                    (order (first-term g)))))))
        (let ((new-n (mul-term-by-all-terms (make-term 0 factor) n))
              (new-d (mul-term-by-all-terms (make-term 0 factor) d)))
          (let ((new-g (gcd-terms new-n new-d)))
            (list (quotient-terms new-n new-g) (quotient-terms new-d new-g)))))))

  (define (reduce-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (let ((new-terms (reduce-terms (term-list p1) (term-list p2))))
        (list (make-poly (variable p1) (car new-terms))
              (make-poly (variable p2) (cadr new-terms))))
      (error "polynomials not in same variable -- REDUCE-POLY" (list p1 p2))))


; b. Did the standard plugging into the packages. Just returning (reduce n d) from make-rat now since reduce gives us a list anyway

; Here's the result. We get the correct answer with simplified integer coefficients, but common factors haven't been removed
; so it's not as simple as the asnwer at the start of the section (which is expected because we didn't do anthing to remove
; common factors, just reduce the coefficients)
1 ]=> (add rf1 rf2)
;Value 83: (rational (polynomial x dense (4 1) (3 1) (2 1) (1 -2) (0 -1)) (polynomial x dense (5 1) (3 -1) (2 -1) (0 1)))



1 ]=> (add rf1 rf1)
;Value 84: (rational (polynomial x dense (1 2) (0 2)) (polynomial x dense (3 1) (0 -1)))

1 ]=> (Add rf2 rf2)
;Value 85: (rational (polynomial x dense (1 2)) (polynomial x dense (2 1) (0 -1)))



