; The good-enough? test used in computing sqrts will not be very effective for finding the sqrt of very small numbers.
; Also, in real computers, arithmetic operations are almost always performed with limited precision. This makes
; our test inadequate for very large numbers. Explain these statements, with examples showing how the test fails for 
; very small and very large numbers.
;
; An alternative strategy for implementing good-enough? is to watch how guess changes from one iteration tot he next 
; and to stop when the change is a very small fraction of the guess. Design a sqrt procedure that uses this kind of 
; end test. Does this work better for small and large numbers?
;
; ====
; Why does good-enough? not work for small numbers? 
; Because we've hard-coded a threshold. Currently, if the difference between x and (square (sqrt x)) is less than .001, then 
; we consider it good enough. But what if we want to find the square root of .0025? We could end up with answers that, when
; squared, produce anything between .0035 and .0015, which would allow huge error. Especially considering that the square of
; sqrt of .0015 could have a range of .0025 to .0005. This means that (sqrt .0025) and (sqrt .0015) have overlapping ranges, 
; and depending on how our guesses work out, .0015 could have a larger square root than .0025.

; Even if this doesn't happen, it's still not very accurate: 
1 ]=> (square (sqrt .0025))
;Value: 2.9417197279678477e-3  << that's off by almost 20%

; For very large numbers, the case is different, but still not good. With large numbers, we loose precision. We start
; to round off, which places a limit on the smallest difference we can detect. If we're rounding by more than .001,
; which we probably would be for very large numbers, then we can't tell whether the two numbers we're looking at are 
; less than .001 apart. Our threshold in this case is too precise and we would never satisfy the condition. With Scheme, the numbers need to be really really 
; large before you run up against this.

1 ]=> (sqrt (square 1000000000000000000000000000))
;Value: 1e27, finishes quickly

1 ]=> (sqrt (square 10000000000000000000000000000))
; Never finishes.

; Now, let's tackle implementing a sqrt procedure that stops when the guess changes only a little bit from one iteration
; to the next. The key change here is that we need to track the old guess and use that for the comparison in good-enough?

(define (sqrt-iter guess old-guess x ) ; added old-guess 
	(if (good-enough? guess old-guess)
		guess
		(sqrt-iter (improve guess x)
					guess ; guess becomes old-guess
					x)))

(define threshold .001)
(define (good-enough? guess old-guess)
	(< (/ (abs (- guess old-guess)) ; how much guess has changed from old guess
			old-guess) 
		threshold)) 

(define (improve guess x)
	(average guess (/ x guess)))

(define (average x y) 
	(/ (+ x y) 2))

(define (square x) (* x x))

(define (sqrt x)
	(sqrt-iter 1.0 10.0 x)) ; use 10.0 as old guess since 10x should be well outside whathever threshold we set in good-enough?

; This works better for the small and large number issues identified above. 
; In the case of the small number, it's much more accurate:
1 ]=> (square (sqrt .0025))
;Value: 2.5000000000746075e-3

;And in the case of the large number, it at least finishes:
1 ]=>  (sqrt (square 10000000000000000000000000000))
;Value: 1.0000002626390475e28

; We get a better answer with a more restrictive threshold:
1 ]=> (define threshold .00001)
;Value: threshold
1 ]=> (sqrt (square 10000000000000000000000000000))
;Value: 1.0000000000000345e28

; This still works fine with .0025:
1 ]=> (square (sqrt .0025))
;Value: 2.5000000000746075e-3

; And works pretty well with simple squares, too:
1 ]=> (sqrt 4)
;Value: 2.000000000000002

1 ]=> (sqrt 144)
;Value: 12.

; That's better than the original implementation. Cool.
