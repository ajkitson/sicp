; By imposing an ordering on variables, extend the polynomial package so that addition and multiplication of polynomials works for
; polynomials in different variables. (This is not easy!)
; =========
; As a first pass, if we're doing an operation on polys (A and B) of two different variables, we'll convert poly B to be the type of
; poly A by simply creating a new poly on the same variable as poly A. This new poly will have one term with an order of 0 and poly
; B as the coefficient: e.g. (y^5 + 1) * (x^3 - 6) -> (y^5 + 1)x^0 * (x^3 - 6)
; 
; For ordering, I'll just go with whichever poly has the highest order term. It's arbitrary but, as the book discusses, there's not
; a good solution to this. Could also do whichever has the most terms (since it'd be the more awkward coefficient). Or go in alpha
; order... anything goes.
;
; Here's our conversion function:
(define (convert-poly poly var)
	(if (eq? var (variable poly)) ; make it so the caller doesn't have to figure out whether the poly really needs to be converted
		poly
	    (make-poly 
	      var
	      (make-dense-termlist (list (make-term 0 (tag poly)))))))  ; retag our original polynomial so we know how to handle it as a coefficient



; Then we can just update the arithmetic operations to replace the not-same-variable error with a conversion:
  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
        (make-poly
            (variable p1)
            (add-terms (term-list p1) (term-list p2)))
        ; (error "Polys not in same var -- ADD POLY" (list p1 p2))))
        (add-poly p1 (convert-poly p2 (variable p1)))))

; This is the same for all the other arithmetic procedures. And now this works:
1 ]=> px
;Value 8: (polynomial x dense (2 1) (1 1))
1 ]=> py
;Value 9: (polynomial y dense (2 1) (1 1) (0 1))
1 ]=> (add px py)
;Value 11: (polynomial x dense (2 1) (1 1) (0 (polynomial y dense (2 1) (1 1) (0 1))))



; Or rather, it works as long as the polynomial with the dominant variable does not have a zero order term. 
; If we were to give px a zero order term (e.g. px = x^2 + x + 5), it breaks:
1 ]=> (add px py)
;No method for these types (raise (complex))
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.

; We get this error because we have only defined how to do arithmetic operations between polynomials. Once we start putting polynomials
; in the coefficients, we have to be able to do arithmetic operations between polynomials and other types of numbers. And to do that
; we need to define how to coerce other numbers to polynomials so we can do math with them.

; To do this, we need to define how to raise numbers to a poly, drop a poly to a simpler number, and define equ? so we can tall whether
; two polynomials are equal (and therefore can be dropped without losing precision). How do we do this? 
;
; We can define a zero-order poly, as when we take one poly and convert it to another variable. But what variable do we use? At,
; First, I thought it didn't matter--we could make up a dummy variable like 'coerced or something like that. But that doesn't 
; quite work. Because if you create a poly with a dummy variable, then it won't match the variable of the poly you're combining it
; with. This means that you either convert the real poly to use the dummy variable and compute a result in the wrong variable. Or
; you convert the (fake) poly with the dummy variable to the variable of the other poly. But that gives you a strangely nested poly.
; When you do that, you have a zero-order poly in the variable that you want, whose one term has a coefficient that is a poly in this
; dummy variable, with just a signle zero order term that's really some other type of number. This causes issues when you combine 
; coefficients -- the nesting compounds and compounds. Ugh.

; So instead, we re-write convert to prevent this. Basically, we create a wrapper for all the poly arithmetic operations that
; will figure out which variable the result should be in. First it checks whether they're already the same--no need to do 
; anything if so. Then it checks whether either poly has a single term and that term is zero-order, in which case it's variable
; doesn't matter. Otherwise, we just take the variable of the first poly. 
;
; That was the key. Updating the arithmetic package to handle polynomials also uncovered a handful of gnarly bugs, so fixed those. 
;
; I made all the changes in arithmetic.scm and have excerpts here.
; Here's the new conversion procedure:
  (define (not-really-a-poly? p)
    (= 0 (order (first-term (term-list p)))))

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


; This allows us to remove the error checking from add-poly, etc. and instead just wrap the call to add-poly, etc:
  (define (add-poly p1 p2)
    (make-poly
        (variable p1)
        (add-terms (term-list p1) (term-list p2))))

  (put 'add '(polynomial polynomial)
      (lambda (x y) (tag (convert-and-apply add-poly x y))))

; All the other arithmetic operations are updated in the same way.

; Then we need to define equ? =zero? and project for polys:

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


(define tower (list 'scheme-number 'rational 'complex 'polynomial))

  (define (complex->polynomial n)  ; poly with one, zero-order term
    (make-polynomial 'coerced (list (list 0 (attach-tag 'complex n)))))

  (put-coercion 'scheme-number 'rational 
    scheme-number->rational)
  (put-coercion 'rational 'complex 
    rational->complex)
  (put-coercion 'complex 'polynomial
    complex->polynomial)
 
   (put 'project '(polynomial)
    (lambda (p) ; just return the zero-th term as a complex number 
      (make-complex-from-real-imag 
          (coeff (get-n-term 0 (term-list p))) 
          0)))




