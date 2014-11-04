; If f is the numerical function and n is a positive integer, then we can form the nth repeated application of f, which is defined to be
; the function whose value at x is f(f(...(f(x))...)). For example, if f is the function x -> x + 1, the nth repeated application of f
; is x -> x + n. If f is the operation squaring a number, then the nth repeated application of f is the function that raises it's 
; argument to the 2^nth power. Write a procedure that takes as inputs a procedure that computes f and a positive integer n and returns
; the procedure that computes the nth repeated application of f. Your procedure should be able to be used as follows:
; ((repeated square 2) 5)
; 625
;
; Hint: You may find it convenient to use compose from exercise 1.42
; ======
; Compose does make it easier, though just a bit. 

(define (compose f g) 
	(lambda (x) (f (g x))))

(define (repeated f n)
	(if (= n 1)
		f
		(repeated (compose f f) (- n 1))))

; Without compose
(define (repeated f n)
	(if (= n 1)
		f
		(repeated (lambda (x) (f (f x))) (- n 1))))
