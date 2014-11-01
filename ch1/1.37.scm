; An infinite continued fraction is an expression of the form:
; f = N1
; 	-----------
; 	D1 +   N2
; 		-----------
; 		D2 + 	N3	
; 			------------
; 			D3 + ......

; As an example, one can show that the infinite continued fraction expression with the Ni and Di all equal to 1 produces 1/phi, where
; phi is the golden ratio. One way to approximate an infinite continued fraction is to truncate the expansion after a given number
; of terms. Such a truncation--a so-called k-term finite continued fraction--has the form:
; f = N1
; 	-----------
; 	D1 +   N2
; 		-----------
; 		D2 + 	Nk	
; 		.... --------
; 				Dk

; Suppose that n and d are procedures of one argument (the term index i) that return Ni and Di of the terms of the continued fraction.
; Define a procedure cont-frac such that evaluating (cont-frac n d k) computes the value of the k-term finite continued fraction. Check
; your procedure by approximating 1/phi using:
; (cont-frac (lambda (i) 1.0)
; 			(lambda (i) 1.0)
; 			k)

; for successive values of k. How large must you make k in order to get an approximation that is accurate to 4 decimal places? 
; If your cont-frac procedure generates a recursive process, make it iterative and vice versa. 
;
; We'll start with a recursive process. This is straightforward. I didn't see a good way to use the accumulators we wrote in previous
; exercises since the value of each term depends no the terms that follow.
(define (cont-frac n d k)
	(define (iter i)
		(/ (n i) 
			(+ (d i) 
				(if (= i k) 0 (iter (+ i 1))))))
	(iter 1))

; function guess target precision
(define (term-precision f guess target precision)
	(let ((val (f guess)))
		(newline)
		(display val)
		(if (<= (abs (- target val)) precision)
			guess
			(term-precision f (+ 1 guess) target precision))))

1 ]=> (term-precision (lambda (k) (cont-frac (lambda (i) 1.0) (lambda (i) 1.0) k)) 1 (/ 1 (/ (+ 1 (sqrt 5)) 2.0)) .00001)

1.
.5
.6666666666666666
.6000000000000001
.625
.6153846153846154
.6190476190476191
.6176470588235294
.6181818181818182
.6179775280898876
.6180555555555556
.6180257510729613
;Value: 12

; So with k = 12 we're within 4 decimal places. Actually, within 11 because I set the target too small

; Now the iterative version:
(define (cont-frac n d k)
	(define (iter i result)
		(if (= i 0)
			result
			(iter (- i 1) (/ (n i) (+ (d i) result)))))
	(iter k 0))
