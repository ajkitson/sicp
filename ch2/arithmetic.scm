(load "utilities.scm")

;; ===========
;; Operation Table procedures (pulled from SO)
(define global-array '())

(define (make-entry k v) (list k v))
(define (key entry) (car entry))
(define (value entry) (cadr entry))

(define (put op type item)
  (define (put-helper k array)
    (cond ((null? array) (list(make-entry k item)))
          ((equal? (key (car array)) k) array)
          (else (cons (car array) (put-helper k (cdr array))))))
  (set! global-array (put-helper (list op type) global-array)))

(define (get op type)
  (define (get-helper k array)
    (cond ((null? array) #f)
          ((equal? (key (car array)) k) (value (car array)))
          (else (get-helper k (cdr array)))))
  (get-helper (list op type) global-array))

;;============
;; Tag support, with scheme-number modifications
(define (attach-tag type-tag contents)
  (if (eq? type-tag 'scheme-number)  ; do this instead of number? check since other types *might* pass in numbers that should be tagged
    contents
    (cons type-tag contents)))

(define (type-tag datum)
  (cond 
    ((number? datum) 'scheme-number)
    ((pair? datum) (car datum))
    (else (error "Bad tagged datum -- TYPE-TAG" datum))))

(define (contents datum)
  (cond 
    ((number? datum) datum)
    ((pair? datum) (cdr datum))
    (else (error "Bad tagged datum -- CONTENTS" datum))))

; ; Two args, no coercion
; (define (apply-generic op . args)
;   (let ((type-tags (map type-tag args)))
;     (let ((proc (get op type-tags)))
;       (if proc
;         (apply proc (map contents args))
;         (error "No method for these types -- APPLY-GENERIC" (list op type-tags))))))

;; Misc supporting procedures, not in table
(define (square n) (mul n n))
(define (variable? x) (symbol? x))
(define (same-variable? x y) (eq? x y))

;; ============
;; ARITTHMETIC PACKAGES
;; Generic operations
(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))
(define (sin-gen n) (apply-generic 'sin n))
(define (cos-gen n) (apply-generic 'cos n))
(define (atan-gen n m) (apply-generic 'atan n m))
(define (sqrt-gen n) (apply-generic 'sqrt n))
(define (greatest-common-divisor a b) (apply-generic 'gcd a b))

;; Predicates -- actual code added to the packages above so they can use selectors, etc.
(define (equ? x y) (apply-generic 'equ? 'no-drop x y))
(define (=zero? x) (apply-generic '=zero? 'no-drop x))


(define (reduce x y) (apply-generic 'reduce x y))

;; Scheme-Number
(define (install-scheme-number-package)

  (define (reduce-integers n d)
  (let ((g (gcd n d)))
    (list (/ n g) (/ d g))))


  (define (tag x) 
    (attach-tag 'scheme-number x))
  (put 'add '(scheme-number scheme-number)
    (lambda (x y) (tag (+ x y))))
  (put 'sub '(scheme-number scheme-number)
    (lambda (x y) (tag (- x y))))
  (put 'mul '(scheme-number scheme-number)
    (lambda (x y) (tag (* x y))))
  (put 'div '(scheme-number scheme-number)
    (lambda (x y) (tag (/ x y))))
  (put 'sqrt '(scheme-number) sqrt)
  (put 'sin '(scheme-number) sin)
  (put 'cos '(scheme-number) cos)
  (put 'atan '(scheme-number scheme-number) atan)

  (put 'equ? '(scheme-number scheme-number)
    (lambda (x y) (= x y)))
  (put '=zero? '(scheme-number)
    (lambda (x) (= x 0)))

  (put 'gcd '(scheme-number scheme-number) gcd)
  (put 'reduce '(scheme-number scheme-number) reduce-integers)

  (put 'make 'scheme-number
    (lambda (x) (tag x)))
  'done)

(define (make-scheme-number n)
  ((get 'make 'scheme-number) n))

(install-scheme-number-package)

;; Rational Number
(define (install-rational-package)
  (define (tag x)
    (attach-tag 'rational x))
  ; (define (make-rat n d) (list n d))
   ; (let ((g (gcd n d)))
     ; (list (div n g) (div d g))))
  (define (make-rat n d) (reduce n d))
  (define (numer r) (car r))
  (define (denom r) (cadr r))
  (define (add-rat x y)
    (if (equ? (denom x) (denom y))
	(make-rat
	 (add (numer x) (numer y))
	 (denom x))
	(make-rat
	 (add
	  (mul (numer x) (denom y))
	  (mul (denom x) (numer y)))
	 (mul (denom x) (denom y)))))
  (define (sub-rat x y)
    (add-rat x 
      (make-rat
        (mul -1 (numer y)) 
        (denom y))))
  (define (mul-rat x y)
    (make-rat
      (mul (numer x) (numer y))
      (mul (denom x) (denom y))))
  (define (div-rat x y)
    (mul-rat x
      (make-rat (denom y) (numer y))))


  (define (to-real n)
    (div (numer n) (denom n)))

  (define (real-fn f)
    (lambda (n) (f (to-real n))))

  (put 'add '(rational rational)
    (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational)
    (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational)
    (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational)
    (lambda (x y) (tag (div-rat x y))))

  (put 'sqrt '(rational) (real-fn sqrt))
  (put 'sin '(rational) (real-fn sin))
  (put 'cos '(rational) (real-fn cos))
  (put 'atan '(rational rational) 
    (lambda (a b) (atan (to-real a) (to-real b))))

  (put 'equ? '(rational rational)
    (lambda (x y) 
      (and (equ? (numer x) (numer y)) 
        (equ? (denom x) (denom y)))))
  (put '=zero? '(rational)
    (lambda (x) (= 0 (numer x))))
  (put 'project '(rational)
    (lambda (x) (div (numer x) (denom x))))
    ; (lambda (x) (round (div (numer x) (denom x))))) ; round to nearest int 
  (put 'make 'rational
    (lambda (n d) (tag (make-rat n d))))

  'done)

(define (make-rational n d)
  ((get 'make 'rational) n d))

(install-rational-package)

;; Complex Packages -- rectangular, polar, generic
(define (install-rectangular-package)
  (define (real-part z) (car z))
  (define (imag-part z) (cdr z))
  (define (make-from-real-imag x y) (cons x y))
  (define (magnitude z)
    (sqrt-gen 
      (add (square (real-part z)) 
        (square (imag-part z)))))
  (define (angle z)
    (atan-gen (imag-part z) (real-part z)))
  (define (make-from-mag-ang r a)
    (cons (* r (cos a)) (* r (sin a))))

  (define (tag x) (attach-tag 'rectangular x))
  (put 'real-part '(rectangular) real-part)
  (put 'imag-part '(rectangular) imag-part)
  (put 'magnitude '(rectangular) magnitude)
  (put 'angle '(rectangular) angle)
  (put 'make-from-real-imag 'rectangular
    (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'rectangular
    (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)

(install-rectangular-package)


(define (install-polar-package) 
  (define (magnitude z) (car z))
  (define (angle z) (cdr z))
  (define (make-from-mag-ang r a) (cons r a))
  (define (real-part z)
    (mul (magnitude z) (cos-gen (angle z)))) 
  (define (imag-part z)
    (mul (magnitude z) (sin-gen (angle z))))
  (define (make-from-real-imag x y)
    (cons 
      (sqrt (add (square x) (square y)))
      (atan y x)))
  (define (tag x) (attach-tag 'polar x))
  (put 'magnitude '(polar) magnitude)
  (put 'angle '(polar) angle)
  (put 'real-part '(polar) real-part)
  (put 'imag-part '(polar) imag-part)
  (put 'make-from-mag-ang 'polar
    (lambda (r a) (tag (make-from-mag-ang r a))))
  (put 'make-from-real-imag 'polar
    (lambda (x y) (tag (make-from-real-imag x y))))
'done)
(install-polar-package)

(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))

(define (install-complex-package)

  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))

  (define (add-complex z1 z2)
    (make-from-real-imag
      (add (real-part z1) (real-part z2))
      (add (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag
      (sub (real-part z1) (real-part z2))
      (sub (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang
      (mul (magnitude z1) (magnitude z2))
      (add (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang
      (div (magnitude z1) (magnitude z2))
      (sub (angle z1) (angle z2))))

  (define (tag x) (attach-tag 'complex x))
  (put 'add '(complex complex) 
    (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub '(complex complex) 
    (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul '(complex complex) 
    (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div '(complex complex) 
    (lambda (z1 z2) (tag (div-complex z1 z2))))

  (put 'equ? '(complex complex)
    (lambda (x y) ; might change to add a tolerance since conversion b/n rect and polar isn't perfect
      (and (equ? (real-part x) (real-part y)) 
        (= (imag-part x) (imag-part y)))))
  (put '=zero? '(complex)
    (lambda (x) (= 0 (magnitude x))))

  (put 'project '(complex)
    (lambda (z) (make-rational (round (real-part z)) 1))) ;round to int or gcd throws a fit


  (put 'make-from-real-imag 'complex
    (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
    (lambda (r a) (tag (make-from-mag-ang r a))))
'done)

(install-complex-package)

(define (make-complex-from-real-imag x y)
  ((get 'make-from-real-imag 'complex) x y))
(define (make-complex-from-mag-ang r a)
  ((get 'make-from-mag-ang 'complex) r a))


;; Polynomials!
(define (install-poly-math-package)

  ;; TERM-LIST PROCEDURES

  ;; Sparse term-list package
  (define (install-sparse-package)
    ; definitions internal to sparse package
    (define (first-term term-list)
      (make-term 
        (length (cdr term-list)) ; order = dist to end of term-list
        (car term-list)))   
   (define (rest-terms term-list)
    (cond
      ((null? (cdr term-list)) '())
      ((= (cadr term-list) 0) (rest-terms (cdr term-list)))  ; if next elem after first = 0, skip and return rest of term-list
      (else (cdr term-list))))

   (define (adjoin-term term term-list)
      (cond 
        ((=zero? (coeff term)) term-list)
        ((= (order term) (length term-list))
          (cons (coeff term) term-list))
        ((> (order term) (length term-list)) 
          (adjoin-term term (cons 0 term-list)))
        (else (error "Adjoining term less than highest term in list -- SPARSE ADJOIN TERM" 
              (list term term-list)))))

    ; hook up to rest of system
    (define (tag x) (attach-tag 'sparse x))
    (put 'first-term '(sparse) first-term)
    (put 'rest-terms '(sparse) 
        (lambda (x) (tag (rest-terms x))))
    (put 'adjoin-term '(term sparse)  ; term is dummy tag to indicate first arg is a term (which doesn't have a type)
        (lambda (term term-list) (tag (adjoin-term term term-list))))
    'done)
  (install-sparse-package)

  ;; dense term-list package
  (define (install-dense-package)
    (define (first-term term-list) (car term-list))
    (define (rest-terms term-list) 
      (cdr term-list))
    (define (adjoin-term term term-list)
      (if (=zero? (coeff term))
        term-list
        (cons term term-list)))

    (define (tag x) (attach-tag 'dense x))
    (put 'first-term '(dense) first-term)
    (put 'rest-terms '(dense) 
        (lambda (x) (tag (rest-terms x))))
    (put 'adjoin-term '(term dense)
        (lambda (term term-list) (tag (adjoin-term term term-list))))
    'done)
  (install-dense-package)

  ; define procedures so they work with either term-list type
  (define (first-term term-list)
      (apply-generic 'first-term 'no-drop term-list))
  (define (rest-terms term-list)
      (apply-generic 'rest-terms 'no-drop term-list))
  (define (adjoin-term term term-list) ; can't use apply-generic since term isn't typed
      ((get 'adjoin-term (list 'term (type-tag term-list))) term (contents term-list)))

  ;term procedures
  (define (make-term order coeff) (list order coeff))
  (define (order term) (car term))
  (define (coeff term) (cadr term))

  (define (the-empty-termlist) '(dense))
  (define (empty-termlist? term-list)
    (null? (contents term-list))) ; no need to do this different per list-type

  (define (add-terms L1 L2)
    (cond 
      ((empty-termlist? L1) L2)
      ((empty-termlist? L2) L1)
      (else 
        (let ((t1 (first-term L1))
              (t2 (first-term L2)))
          (cond 
            ((> (order t1) (order t2))
              (adjoin-term t1 (add-terms (rest-terms L1) L2)))
            ((< (order t1) (order t2))
              (adjoin-term t2 (add-terms L1 (rest-terms L2))))
            (else 
              (adjoin-term
                (make-term 
                  (order t1) 
                  (add (coeff t1) (coeff t2)))
                (add-terms (rest-terms L1) (rest-terms L2)))))))))

  (define (negate-list terms)
    (mul-term-by-all-terms (make-term 0 -1) terms))

  (define (sub-terms L1 L2)
    (add-terms L1 (negate-list L2)))

  (define (mul-terms L1 L2)
    (if (empty-termlist? L1) 
        (the-empty-termlist)
        (add-terms
            (mul-term-by-all-terms (first-term L1) L2)
            (mul-terms (rest-terms L1) L2))))

  (define (mul-term-by-all-terms t L)
    (if (empty-termlist? L)
        (the-empty-termlist) 
        (let ((next-term (first-term L)))
            (adjoin-term
                (make-term
                  (add (order t) (order next-term))
                  (mul (coeff t) (coeff next-term)))
                (mul-term-by-all-terms t (rest-terms L))))))

  (define (quotient-terms numer-terms denom-terms)
    (car (div-terms numer-terms denom-terms)))

  (define (remainder-terms numer-terms denom-terms)
    (cadr (div-terms numer-terms denom-terms)))

  (define (pseudoremainder-terms P Q)
    (let ((O1 (order (first-term P)))
          (O2 (order (first-term Q)))
          (c (coeff (first-term Q))))
      (let ((int-factor (expt c (+ 1 (- O1 O2)))))
        (remainder-terms 
          (mul-term-by-all-terms
              (make-term 0 int-factor)
              P)
          Q))))

  (define (div-terms numer-terms denom-terms)
    (if (empty-termlist? numer-terms)  ; divisor is zero, no remainder
    	(list (the-empty-termlist) (the-empty-termlist))
      (let ((n (first-term numer-terms))
	    (d (first-term denom-terms)))
        (if (> (order d) (order n)) ; base case -> dividend greater than divisor, so divisor becomes remainder, quotient is zero
          (list (the-empty-termlist) numer-terms) ;TODO: update empty-term-list to attach its own tag
          (let ((new-o (sub (order n) (order d)))
		(new-c (div (coeff n) (coeff d))))
            (let ((rest-of-result 
                  (div-terms 
                    (sub-terms 
                      numer-terms 
                      (mul-term-by-all-terms (make-term new-o new-c) denom-terms))  ; new dividend = (current dividend - newest term * divisor)
                    denom-terms)))
              (list 
                (adjoin-term (make-term new-o new-c) (car rest-of-result)) ; add first term to quotient
                (cadr rest-of-result)) ; remainder stays the same
              ))))))

  ; (define (gcd-terms a b)
  ;   (if (empty-termlist? b)
  ;     	a
  ;     	(gcd-terms b (pseudoremainder-terms a b))))

  
  (define (map-terms op L)
    (if (empty-termlist? L)
      '()
      (cons (op (first-term L)) (map-terms op (rest-terms L)))))

  (define (gcd-terms a b)
    (if (empty-termlist? b)
        (let ((div-by (apply gcd (map-terms coeff a))))
          (quotient-terms a (make-dense-termlist (list (make-term 0 div-by)))))
        (gcd-terms b (pseudoremainder-terms a b))))


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

  ;; Polynomial procedures
  ;; Basic constructors, selectors
  (define (make-poly var term-list)
    (cons var term-list))
  (define (make-dense-termlist terms)
    (attach-tag 'dense terms))
      ; (cons var (attach-tag 'dense term-list)))
  ; (define (make-poly-sparse var term-list)
  ;     (cons var (attach-tag 'sparse term-list)))
  (define (variable p)
      (car p))
  (define (term-list p)
      (cdr p)) ; do I need to change this to cadr when I separate poly types?

  ;; Polynomial arithmetic
  (define (add-poly p1 p2)
    (make-poly
        (variable p1)
        (add-terms (term-list p1) (term-list p2))))

  (define (mul-poly p1 p2)
    (make-poly
        (variable p1)
        (mul-terms (term-list p1) (term-list p2))))
  
  (define (sub-poly a b)
    (make-poly (variable a) (sub-terms (term-list a) (term-list b))))

  (define (div-poly p1 p2)
    (let ((result (div-terms (term-list p1) (term-list p2))))
      (list
       (make-poly (variable p1) (car result))
       (make-poly (variable p1) (cadr result)))))

  (define (not-really-a-poly? p)
    (= 0 (order (first-term (term-list p)))))


  ;; if zero-term >> just convert to other, no wrapping
  ;; otherwise, make zero-term
  (define (convert-and-apply op p1 p2)
    (cond ((same-variable? (variable p1) (variable p2))
            (op p1 p2))
          ((not-really-a-poly? p1)
              (op (make-poly (variable p2) (term-list p1)) p2))
          ((not-really-a-poly? p2)
              (op p1 (make-poly (variable p1) (term-list p2))))
          ((op 
              p1
              (make-poly
                  (variable p1)
                  (make-dense-termlist (list (make-term 0 (tag p2)))))))))

  (define (get-n-term n term-list)
    (define (empty-term) (make-term 0 0))
    (if (empty-termlist? term-list)
    	(empty-term)
    	(let ((term (first-term term-list)))
    	  (cond ((= n (order term)) term) ; found it
          		((< n (order term))       ; not there yet
      		        (get-n-term n (rest-terms term-list)))
          		(else (empty-term)))))) ; not in list
    
  (define (equ-terms? terms1 terms2)
    (if (and (empty-termlist? terms1) (empty-termlist? terms2))
       true
       (let ((t1 (first-term terms1)) (t2 (first-term terms2)))
          (if (and (= (order t1) (order t2)) ; order and coeff the same
                   (equ? (coeff t1) (coeff t2)))
            (equ-terms? (rest-terms terms1) (rest-terms terms2))
            false))))

  (define (equ-poly? p1 p2)
    (or (and (eq? (variable p1) (variable p2))            ; same var and all terms the same
             (equ-terms? (term-list p1) (term-list p2)))
        (and (not-really-a-poly? p1)
             (not-really-a-poly? p2))))

  (define (gcd-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	    (make-poly (variable p1) (gcd-terms (term-list p1) (term-list p2)))
      (error "Polynomials not in same variable -- GCD-POLY" (list p1 p2))))
    

  (define (tag x) (attach-tag 'polynomial x))
  (put 'add '(polynomial polynomial)
      (lambda (x y) (tag (convert-and-apply add-poly x y))))
  (put 'sub '(polynomial polynomial)
      (lambda (x y) (tag (convert-and-apply sub-poly x y))))
  (put 'mul '(polynomial polynomial)
      (lambda (x y) (tag (convert-and-apply mul-poly x y))))
  (put 'div '(polynomial polynomial)
      (lambda (x y) 
      	(let ((result (convert-and-apply div-poly x y)))
      	  (newline)
      	  (if (empty-termlist? (term-list (car result))) ; if only a remainder, return 0 since rest of system doesn't know how to handle remainders
      	      0
      	      (tag (car result))))))
  (put 'reduce '(polynomial polynomial)
      (lambda (x y) 
        (let ((new-polys (reduce-poly x y)))
          (list (tag (car new-polys)) 
                (tag (cadr new-polys))))))

  (put 'gcd '(polynomial polynomial) 
       (lambda (p1 p2) (tag (gcd-poly p1 p2))))

  (put 'make-dense 'polynomial
      (lambda (var terms) 
        (tag (make-poly var 
                        (attach-tag 'dense terms)))))
  (put 'make-sparse 'polynomial
      (lambda (var terms) 
        (tag (make-poly var 
                        (attach-tag 'sparse terms)))))
  (put '=zero? '(polynomial) empty-termlist?) 
  (put 'equ? '(polynomial polynomial) equ-poly?)

  (put 'project '(polynomial)
    (lambda (p) ; just return the zero-th term as a complex number 
      (make-complex-from-real-imag 
          (coeff (get-n-term 0 (term-list p))) 
          0)))

  'done)

(install-poly-math-package)

(define (make-polynomial var terms)
  ((get 'make-dense 'polynomial) var terms))
(define (make-polynomial-sparse var terms)
  ((get 'make-sparse 'polynomial) var terms))


;; COERCION!
; Starting with simple 
(define (put-coercion from-type to-type proc)
  (put 'coerce (list from-type to-type) proc))
(define (get-coercion from-type to-type)
  (get 'coerce (list from-type to-type)))

(define (install-coercions)
  (define (scheme-number->rational n) 
    (make-rational (round (* n 10000)) 10000)) ; make rounding more precise
   ; (make-rational (round n) 1))  ; need round in case n is not an int... otherwse gcd complains in make-rational
  (define (rational->complex n)
    (make-complex-from-real-imag 
      (attach-tag 'rational n) ;;make sure we store as rational embedded in complex 
      0))
  (define (complex->polynomial n)  ; poly with one, zero-order term
    (make-polynomial 'coerced (list (list 0 (attach-tag 'complex n))))) ; drop n as far as we can before making the poly

  (put-coercion 'scheme-number 'rational 
    scheme-number->rational)
  (put-coercion 'rational 'complex 
    rational->complex)
  (put-coercion 'complex 'polynomial
    complex->polynomial)
 
 'done)

(install-coercions)

; Using these, we can define drop:
(define (drop n)
  (if (or (= -1 (position (type-tag n) tower)) ; our type is lowest in the tower (or not in the tower) -> can't be dropped further
      (eq? (type-tag n) (car tower)))  
    n
    (let ((lower-n (project n)))
      (if (equ? n (raise lower-n)) ; drop further if we don't lose precision, otherwise stop with n
        (drop lower-n)
        n))))

; Now let's get project set up. First defer to apply-generic:
(define (project n)
  (apply-generic 'project 'no-drop n)) ; specific versions of project are in individual packages

(define (install-raise)
  (define (coerce n type1 type2)
    ((get-coercion type1 type2) n))

  (put 'raise '(scheme-number) ; integer->rational
    (lambda (n) (coerce n 'scheme-number 'rational)))
  (put 'raise '(rational)       ; rational->complex
    (lambda (n) (coerce n 'rational 'complex)))
  (put 'raise '(complex)
    (lambda (n) (coerce n 'complex 'polynomial)))
  'done)

(define (raise n)
  (apply-generic 'raise 'no-drop n))

(install-raise)


(define tower (list 'scheme-number 'rational 'complex 'polynomial))
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

(define (raises-to typeA typeB)
  (before typeA typeB tower))

(define (highest-type num-types)
  (accumulate
    (lambda (n max) (if (raises-to n max) max n))
    (car num-types)
    (cdr num-types)))

(define (raise-until n type)
  (if (eq? (type-tag n) type)
    n   ; got the type we're looking for
    (raise-until (raise n) type)))

; (define (apply-generic op . args)
;   (define (lookup-error op tags)
;     (error "No method for these types" (list op tags)))
;   (let ((type-tags (map type-tag args)))
;     (let ((proc (get op type-tags)))
;       (if proc
;         (apply proc (map contents args))
;         (let ((coerce-to-type (highest-type type-tags)))
;           (if (every  ;; every type is already the highest type --> nothing to coerce to!
;               (lambda (type) (equal? type coerce-to-type)) 
;               type-tags)
;             (lookup-error op type-tags)
;             (apply ; have to use apply here or args could get nested in one too many lists
;               apply-generic
;               (cons 
;                 op 
;                 (map (lambda (a) (raise-until a coerce-to-type)) args)))))))))


; with drop
; (define (apply-generic op . args)
;   (newline)
;   (display (list "apply-generic" op args))
;   (define (lookup-error op tags)
;     (error "No method for these types" (list op tags)))
;   (define (apply-generic-internal args)
;     (let ((type-tags (map type-tag args)))
;       (display (list "tags" type-tags))
;       (let ((proc (get op type-tags)))
;         (if proc
;             (apply proc (map contents args))
;           (let ((coerce-to-type (highest-type type-tags)))
;             (if (every  ;; every type is already the highest type --> nothing to coerce to!
;                 (lambda (type) (equal? type coerce-to-type)) 
;                 type-tags)
;               (lookup-error op type-tags)
;               (apply ; have to use apply here or args could get nested in one too many lists
;                 apply-generic
;                 (cons 
;                   op 
;                   (map (lambda (a) (raise-until a coerce-to-type)) args)))))))))
;   (if (eq? 'no-drop (car args))
;     (apply-generic-internal (cdr args))
;     (drop (apply-generic-internal args))))

(define (apply-generic op . args)
  ; (newline)
  ; (display (list "apply-generic" op args)) 
  (define (lookup-error op tags)	
    (error "No method for these types" (list op tags)))
  (let ((no-drop (eq? (car args) 'no-drop)))
    (define (apply-generic-internal args)
      (let ((type-tags (map type-tag args)))
        (let ((proc (get op type-tags)))
          (if proc        ;; found proc so apply it
              (apply proc (map contents args))
              (if (every  ;; all of same type = nothing to convert = error
                    (lambda (type) (eq? type (car type-tags))) 
                    type-tags)
                (lookup-error op type-tags)
                (let ((coerce-to-type (highest-type type-tags)))
                  (let ((coerced-args (map (lambda (arg) (raise-until arg coerce-to-type)) args)))
                    (if no-drop
                      (apply apply-generic (cons op (cons 'no-drop coerced-args)))
                      (apply apply-generic (cons op coerced-args))))))))))
    (if no-drop
      (apply-generic-internal (cdr args))
      (drop (apply-generic-internal args)))))


