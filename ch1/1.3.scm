; Define a procedure that takes 3 numbers and return the sum of the squares of the two larger numbers


; (define (square x) (* x x))

; (define (max a b) 
; 	(if (> a b) a b))

; (define (sum-squares-of-max-two a b c)
; 	(+ (square (max a b)) 
; 		(square (max c (if (= a (max a b)) b a))))) ; compare c to lesser of a and b


; ; Here we define the utility functions within the larger function
; (define (sum-squares-of-max-two a b c)
; 	(define (square x) (* x x))
; 	(define (max a b) 
; 		(if (> a b) a b))
; 	(+ (square (max a b)) 
; 		(square (max c (if (= a (max a b)) b a)))) ; compare c to lesser of a and b
; )

; is this any faster? Just don't like doing (max a b) twice...
(define (sum-squares-of-max-two a b c)
	(define (square x) (* x x))
	(define (max a b) 
		(if (> a b) a b))
	(define maxAB (max a b))
	(+ (square maxAB) 
		(square (max c (if (= a maxAB) b a)))) ; compare c to lesser of a and b
)
