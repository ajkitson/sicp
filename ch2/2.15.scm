; Eva Lu Ator, another user, has also noticed the different intervals computed by different but algebraically equivalent expressions.
; She says that a formula to compute with intervals using Alyssa's system will produce tighter error bounds if it can be written in 
; such a form that no variable that represents an uncertain number is repeated. Thus, she says, par2 is a "better" program for parallel
; resistances than par1. Is she right? Why?
; ======
; Well, Eva has been right in the past. She probably is this time, too.
; But in this case we can see why she's right. In 2.14 we saw how arithmetic operations distort the intervals, with addition and 
; subtraction causing the width to grow, and multiplication and division causing the center to shift and width to grow.
;
; However, this only happens when there are two uncertain values involved. When one interval has a width of zero, we don't see the 
; same distortions:
1 ]=> (define u (make-interval 9 11))
1 ]=> (define c (make-interval 20 20))
1 ]=> (div-interval (mul-interval c u) c)   ; we get original value because we  divide an uncertain value by a certain one (expresssed as an interval)
;Value 19: (9. . 11.)
1 ]=> (div-interval (mul-interval c u) u)	; we get a distorted value because we divide an uncertain value (c * u) by an uncertain one
;Value 20: (16.363636363636363 . 24.444444444444443)

; For calculating parallel resistences, the only source of uncertainty is introduced by R1 and R2. We therefore only increase uncertainty
; when doing an operation where both values are somehow produced from R1 or R2. Each time we operate on two uncertain values (from R1 
; or R2) we increase uncertainty. Now, if R1 and R2 are not repeated, then we can only have this type of operation once--the first 
; time we combine R1 and R2, and that increase in uncertainty is unavoidable and irreducible. If we repeat R1 and R2, we necessarily 
; have more operations that combine two uncertain values. In fact, you could count the number of these operations to get a sense of
; how much extra uncertainty to expect. In any case, that's why Eva is correct, because more instances of variables representing 
; uncertain values means more operations combining uncertain values and therefore greater error.
