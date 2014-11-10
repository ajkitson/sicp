; Show that under the assumption of small percentage tolerances there is a simple formula for the approximate percentage tolerance of the
; product of two intervals in terms of the tolerances of the factors. You may simplify the problem by assuming that all numbers are 
; positive.
; ====
; Let's walk through an example or two to get a feel for the relationship.
;
1 ]=> (define a (make-interval 99 101))
1 ]=> (percent a)
;Value: 1
1 ]=> (define b (make-interval 199 201))
1 ]=> (percent b)
;Value: .5
1 ]=> (percent (mul-interval a b))
;Value: 1.499925003749812



1 ]=> (define c (make-interval 97 103))
1 ]=> (percent c)
;Value: 3.
1 ]=> (define d (make-interval 9999 10001))
1 ]=> (percent d)
;Value: .01
1 ]=> (percent (mul-interval c d))
;Value: 3.00999097002709

; So it seems we just add the tolerances. Let's see if we can show this a bit more rigorously
; Suppose you have two intervals with centers a and b, and width, x and y, respectively
; The lower bound of the product of these intervals is (a - x) * (b - y) and the upper bound is (a + x) * (b + y).
; The width is therefore ((a + x) * (b + y) - ((a - x) * (b - y))) / 2
; The center is ((a + x) * (b + y) + ((a - x) * (b - y))) / 2
; The tolerance is the width / center, so it is
; (((a + x) * (b + y) - ((a - x) * (b - y))) / 2) / (((a + x) * (b + y) + ((a - x) * (b - y))) / 2)

; Let's reduce this:
; (((a + x) * (b + y) - ((a - x) * (b - y))) / 2) * (2 / ((a + x) * (b + y) + ((a - x) * (b - y))))
; ((a + x) * (b + y) - ((a - x) * (b - y))) / ((a + x) * (b + y) + ((a - x) * (b - y)))
; ab + ay + bx + xy - (ab -ay - bx + xy) / ab + ay + bx + xy + ab - ay - bx + xy
; (ay + bx) / (ab + xy)
;
; Now, if the tolerance is small, it's xy's contribution to the divisor is small, too, so (ay + bx) / (ab + xy) is approximately
; (ay + bx) / ab, which we can restate as ay / ab + bx / ab, or better yet: y/b + x/a. Hey! This is the sum or our original widths
; divided by our original centers. Or, in other words, the sum of the original tolerances. Cool.






; So the width is ay + bx + by. Now, to get the tolerance, we divide the width by the center, which is ab, so the tolerance is
; (ay + bx + xy) / ab

