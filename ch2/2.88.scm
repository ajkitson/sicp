; Extend the polynomial system to include subtraction of polynomials. (Hint: You may find it helpful to define a generic negation
; operation)
; =====
; Following the hint, we'll create a negate operation that multiplies a poly by -1 and then define subtraction as addition where teh 
; second operand is negated. I'm not sure if the hint suggested making this truly generic (as in for all types). I added it internally
; to the poly package and it enables subtractions. I'll move it to other packages and add a generic definition later if htere's a 
; clear reason to do so

  (define (negate-poly p)
    (mul-poly p ; multiply p by -1 in poly form (-1x^0 )
      (make-poly (variable p) (list (make-term 0 -1)))))

  (define (sub-poly a b)
    (add-poly a (negate-poly b)))

; Added this to the package with the normal stuff, and here it is in action:

1 ]=> a
;Value 164: (polynomial x (2 1) (0 5))
1 ]=> b
;Value 172: (polynomial x (4 2) (2 (rational 5 1)))
1 ]=> (sub a b)
;Value 186: (polynomial x (4 -2) (2 -4) (0 5))
1 ]=> (sub b a)
;Value 187: (polynomial x (4 2) (2 4) (0 -5))

; UPDATE! In 2.91, I had to subtract terms and not just polynomials, so switched everything over to do the subtraction at the level
; of terms

  (define (negate-list terms)
    (mul-term-by-all-terms (make-term 0 -1) terms))

  (define (sub-terms L1 L2)
    (add-terms L1 (negate-list L2)))

  (define (sub-poly a b)
    (make-poly (variable a) (sub-terms (term-list a) (term-list b)))) 
