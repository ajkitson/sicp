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

;; Predicates -- actual code added to the packages above so they can use selectors, etc.
(define (equ? x y) (apply-generic 'equ? 'no-drop x y))
(define (=zero? x) (apply-generic '=zero? 'no-drop x))


;; Scheme-Number
(define (install-scheme-number-package)
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
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (list (div n g) (div d g))))
  (define (numer r) (car r))
  (define (denom r) (cadr r))
  (define (add-rat x y)
    (make-rat
      (add
        (mul (numer x) (denom y))
        (mul (denom x) (numer y)))
      (mul (denom x) (denom y))))
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
    (/ (numer n) (denom n)))

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
      (and (= (numer x) (numer y)) 
        (= (denom x) (denom y)))))
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
    (mul (magnitude z) (cos-gen (angle z)))) ;ISSUE MUST BE HERE, WITH HOW WE HANDLE RATIONALS....
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
      ((null? (cdr term-list)) (the-empty-termlist))
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
      (apply-generic 'first-term term-list))
  (define (rest-terms term-list)
      (apply-generic 'rest-terms term-list))
  (define (adjoin-term term term-list) ; can't use apply-generic since term isn't typed
      ((get 'adjoin-term (list 'term (type-tag term-list))) term (contents term-list)))

  ;term procedures
  (define (make-term order coeff) (list order coeff))
  (define (order term) (car term))
  (define (coeff term) (cadr term))

  (define (the-empty-termlist) '())
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

  (define (mul-terms L1 L2)
    (if (empty-termlist? L1) 
        L1      ; return L1 so we retain type-tag
        (add-terms
            (mul-term-by-all-terms (first-term L1) L2)
            (mul-terms (rest-terms L1) L2))))

  (define (mul-term-by-all-terms t L)
    (if (empty-termlist? L)
        L     ; return L so we retain type-tag
        (let ((next-term (first-term L)))
            (adjoin-term
                (make-term
                  (add (order t) (order next-term))
                  (mul (coeff t) (coeff next-term)))
                (mul-term-by-all-terms t (rest-terms L))))))

  ;; Polynomial procedures
  ;; Basic constructors, selectors
  (define (make-poly var term-list)
    (cons var term-list))
      ; (cons var (attach-tag 'dense term-list)))
  ; (define (make-poly-sparse var term-list)
  ;     (cons var (attach-tag 'sparse term-list)))
  (define (variable p)
      (car p))
  (define (term-list p)
      (cdr p)) ; do I need to change this to cadr when I separate poly types?

  ;; Polynomial arithmetic
  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
        (make-poly
            (variable p1)
            (add-terms (term-list p1) (term-list p2)))
        (error "Polys not in same var -- ADD POLY" (list p1 p2))))

  (define (mul-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
        (make-poly
            (variable p1)
            (mul-terms (term-list p1) (term-list p2)))
        (error "Polys not in same var -- MUL POLY" (list p1 p2))))
  
  (define (negate-poly p)
    (mul-poly p ; multiply p by -1 in poly form (-1x^0 )
      (make-poly (variable p) (list (make-term 0 -1)))))

  (define (sub-poly a b)
    (add-poly a (negate-poly b)))


  (define (tag x) (attach-tag 'polynomial x))
  (put 'add '(polynomial polynomial)
      (lambda (x y) (tag (add-poly x y))))
  (put 'sub '(polynomial polynomial)
      (lambda (x y) (tag (sub-poly x y))))
  (put 'mul '(polynomial polynomial)
      (lambda (x y) (tag (mul-poly x y))))
  (put 'make-dense 'polynomial
      (lambda (var terms) 
        (tag (make-poly var 
                        (attach-tag 'dense terms)))))
  (put 'make-sparse 'polynomial
      (lambda (var terms) 
        (tag (make-poly var 
                        (attach-tag 'sparse terms)))))
  (put '=zero? '(polynomial) empty-termlist?) 
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

  (put-coercion 'scheme-number 'rational 
    scheme-number->rational)
  (put-coercion 'rational 'complex 
    rational->complex)
 
 'done)

(install-coercions)

; Updated apply-generic to try coercion
; (define (apply-generic op . args)
;   (define (lookup-error op tags)
;     (error "No method for these types" (list op tags)))
;   (let ((type-tags (map type-tag args)))
;     (let ((proc (get op type-tags)))
;       (if proc
;         (apply proc (map contents args)) 
;         (if (and (= (length args) 2) 
;             (not (eq? (car type-tags) (cadr type-tags))))  ; ADDED to prevent attempted coercion on same type
;           (let 
;             ((type1 (car type-tags))
;               (type2 (cadr type-tags))
;               (a1 (car args))
;               (a2 (cadr args)))
;             (let 
;               ((t1->t2 (get-coercion type1 type2))
;               (t2->t1 (get-coercion type2 type1)))
;               (cond
;                 (t1->t2 (apply-generic op (t1->t2 a1) a2))
;                 (t2->t1 (apply-generic op a1 (t2->t1 a2)))
;                 (else (lookup-error op type-tags)))))
;           (lookup-error op type-tags))))))


; (define (apply-generic op . args)
;   (define (every test elements)
;     (cond
;       ((null? elements) true)
;       ((test (car elements)) (every test (cdr elements)))
;       (else false)))
;   (define (some test elements)
;     (cond 
;       ((null? elements) false)
;       ((test (car elements)) (car elements))
;       (else (some test (cdr elements)))))
;   (define (find-coercion-type types) ; find first type where every other type converts to it
;     (some 
;       (lambda (target)
;         (every 
;           (lambda (test) 
;             (or 
;               (eq? test target) 
;               (get-coercion test target))) ; either same type or coercion procedure exists
;           types))
;       types))
;   (define (convert-args-to-type target-type args)
;     (map 
;       (lambda (a)
;         (if (eq? (type-tag a) target-type)
;           a
;           ((get-coercion (type-tag a) target-type) a))) ; get and perform coercion
;       args))
;   (define (lookup-error op tags)
;     (error "No method for these types" (list op tags)))
;   (let ((type-tags (map type-tag args)))
;     (let ((proc (get op type-tags)))
;       (if proc
;         (apply proc (map contents args))
;         (if (some ; not already all the same type
;               (lambda (t) (not (eq? t (car type-tags))))
;               type-tags) 
;           (let ((target-type (find-coercion-type type-tags)))
;             (if target-type  
;               (apply ;if we have a target type, map all args to this type and call apply-generic again
;                 apply-generic 
;                 (cons op (convert-args-to-type target-type args)))
;               (lookup-error op type-tags)))
;           (lookup-error op type-tags))))))

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
  (apply-generic 'project 'no-drop n))

(define (install-raise)
  (define (coerce n type1 type2)
    ((get-coercion type1 type2) n))

  (put 'raise '(scheme-number) ; integer->rational
    (lambda (n) (coerce n 'scheme-number 'rational)))
  (put 'raise '(rational)       ; rational->complex
    (lambda (n) (coerce n 'rational 'complex)))
  'done)

(define (raise n)
  (apply-generic 'raise 'no-drop n))

(install-raise)


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


