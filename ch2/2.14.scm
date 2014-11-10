; Demonstrate that Lem is right. Investigate the behaviour of the system on a variety of arithmetic epxressions. Make some intervals A
; and B, and use them in computing the expressions A/A and A/B. You will get the most insight by using intervals whose width is a small
; percentage of the center value. Examine the results of the computation in center-percent form (from exerice 2.12).
; ====
; Lem's complaint with Alyssa's interval arithmetic is that algebraicly equaivalent procedures produce different results. Specifically,
; he points out that these two formula for parallel resistors should be the same but aren't: R1*R2/(R1 + R2) and 1 / (1/R1 + 1/R2).
; He wrote these procedures to illustrate the point:
(define (par1 r1 r2)
	(div-interval 
		(mul-interval r1 r2) 
		(add-interval r1 r2)))

(define (par2 r1 r2)
	(let ((one (make-interval 1 1)))
		(div-interval 
			one
			(add-interval
				(div-interval one r1)
				(div-interval one r2)))))

; Let's see wether Lem is right. First we'll test with intervals that have no width (basically numbers), just to make sure the 
; procedures work and produce the same result if fed numbers:
1 ]=> (define a (make-interval 100 100))
1 ]=> (define b (make-interval 400 400))
1 ]=> (par1 a b)
;Value 4: (80 . 80)
1 ]=> (par2 a b)
;Value 5: (80 . 80)

; OK, those are the same. Good. Now let's do some real intervals:
1 ]=> a
;Value 8: (99 . 101)
1 ]=> b
;Value 9: (399 . 401)
1 ]=> (par1 a b)
;Value 10: (78.68725099601593 . 81.32730923694778)
1 ]=> (par2 a b)
;Value 11: (79.31927710843372 . 80.6792828685259)

; Now we're starting to diverge, so Lem is right. I mentioned something like this in 2.6 when making the sub-interval. I was 
; disconcerted that a + a - a != a. The width increased with each operation.
; We'll do some examples where we perform some manipulations that should yield our starting value, but diverge significantly when
; we apply them repeatedly. For example a + (a - a + a - a...) should be a, but it isn't. (a * a) / a should be a, but it isn't.
; Here's a loop we'll use to run these a few times:
(define (loop-n f x n)
	(display (center x))
	(display " ")
	(display (percent x))
	(newline)
	(if (= n 0)
		(display "done!")
		(loop-n f (f x) (- n 1))))

; Now check out what happens when we do a + a - a + a.... :
1 ]=> (define a (make-interval 99 101))

;Value: a

1 ]=> (loop-n (lambda (i) (sub-interval (add-interval i i) i)) a 10)
100 1.
100 3.
100 9.
100 27.
100 81.
100 243.00000000000003
100 729.
100 2187.
100 6561.
100 19683.
100 59049.
done!

; After we've added a to itself and then subtracted a just a couple times we're waaay off. Note that the center is the same, but our
; tolerances make the whole thing practically meaningless.

; And here we have division and multiplication:
(loop-n (lambda (i) (div-interval (mul-interval i i) i)) a 10)
100 1.
100.04000400040005 2.999200239928031
100.40028009682362 8.97607607555417
103.66225973394074 26.36332104723537
134.6340047523455 66.96051547630726
572.3629768739297 98.46207208674596
73292.71397413929 99.99990693097426
157501693363.90323 100.
1.5630004577977257e30 100.
1.5274983106942452e87 100.
1.4257574145968388e258 100.
; This is even worse. Now our center is moving, and the tolerance tends to 100%.

