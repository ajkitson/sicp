; Suppose we want to have a polynomial system that is efficient for both sparse and dense polynomials. One way to do this is to allow
; both kinds of term-list representations in our system. The situation is analogous to the complex-number example of section 2.4, where
; we allowed both rectangular and polar representations. To do this we must distinguish different types of term lists and make the 
; operations on term lists generic. Redesign the polynomial system to implement this generalization. This is a major effort, not a 
; local change.
; =======
; To be clear, we're tagging the term-lists, not the polynomials. This will allow us to use the same procedures for all non-list 
; operators. Really, we just need to have different versions of the operations we set up in 2.89: first-term, rest-terms, adjoin-term.
; All the others we can continue to use the same (e.g. empty-termlist, etc.).
;
; Also, because the polynomial package is the only one that cares about the difference in term-list representations, we'll keep all 
; of this internal to that package.
;
; So here's what we'll do:
; - create packages for dense and sparse term-lists, each with their own versions of first-term, rest-terms, and adjoin-term
; - add generic procedure definitions in the poly package (defering to apply-generic)
; - tag the lists appropriately so we know how to minupulate them. Do this when we create the poly as that's the only time we create
; 	the list from scratch. We'll define a procedure to use a sparse list. The default make-poly will use a dense list. 
;
; This should take care of it. Let's see!
;
; Whew! I got most of it, but there were some details I wasn't anticipating. For example, in mul-terms, when we hit an empty list, 
; instead of returning the generic empty list we should return our empty list param so we retain the proper type-tag.

; Update package is below. Here they are in action:
; Works with dense representation:
1 ]=> a
;Value 207: (polynomial x dense (2 1) (0 5))
1 ]=> b
;Value 211: (polynomial x dense (4 2) (2 5))
1 ]=> (mul a b)
;Value 212: (polynomial x dense (6 2) (4 15) (2 25))
1 ]=> (add a b)
;Value 213: (polynomial x dense (4 2) (2 6) (0 5))


; And with the sparse represntation:
1 ]=> a
;Value 214: (polynomial x sparse 1 0 5)
1 ]=> b
;Value 215: (polynomial x sparse 2 0 5 0 0)
1 ]=> (mul a b)
;Value 222: (polynomial x sparse 2 0 15 0 25 0 0)
1 ]=> (add a b)
;Value 223: (polynomial x sparse 2 0 6 0 5)
1 ]=> (sub a b)
;Value 224: (polynomial x sparse 1 0 5)

; And mixed representations!
1 ]=> a
;Value 214: (polynomial x sparse 1 0 5)
1 ]=> b
;Value 225: (polynomial x dense (4 2) (2 5))
1 ]=> (add a b)
;Value 228: (polynomial x sparse 2 0 6 0 5)
1 ]=> (mul a b)
;Value 229: (polynomial x dense (6 2) (4 15) (2 25))




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



