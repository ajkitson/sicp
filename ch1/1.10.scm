; The following procedure computes a function called Ackerman's function:
(define (A x y)
	(cond ((= y 0) 0)
		((= x 0) (* 2 y))
		((= y 1) 2)
		(else (A (- x 1)
				(A x (- y 1))))))

; What are the values for the following expressions? 
1 ]=> (A 1 10)
;Value: 1024

1 ]=> (A 2 4)
;Value: 65536

1 ]=> (A 3 3)
;Value: 65536

; Give concise mathematical description of these procedures, where A is the procedure defined above.
(define (f n) (A 0 n))
;=> f(n) = 2n

(define (g n) (A 1 n))
; (A 1 n)
; (A 0 (A 1 n-1))
; (2 * (A 1 n-1))
; (2 * (A 0 (A 1 n-2)))
; (2 * (2 * (A 1 n-2)))
; .... until n = 1
; (2 * (2 * ... (A 1 1)))
; (2 * (2 * ... 2))
; g(n) = 2^n

(define (h n) (A 2 n))
; (A 2 n)
; (A 1 (A 2 n-1))
; (A 1 (A 1 (A 2 n-2))
; (A 1 (A 1 ( A 1 (A 2 n-3))))
; ....until n = 1, upon which (A 2 1) = 2:
; (A 1 (A 1 (A 1... (A 1 (A 2 1)))))
; (A 1 (A 1 (A 1... (A 1 2))))
; Now, we know from above the (A 1 n) is 2^n, and we have (A 1 (A 1 ...)) n times over, so ...
; h(n) = 2^n^n

(define (k n) (* 5 n n))
; k(n) = 5n^2