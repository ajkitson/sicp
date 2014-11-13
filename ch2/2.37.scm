; Suppose we represent vectors v = (vi) as sequences of numbers, and matrices m = (mij) as sequences of vectors (the rows of the 
; matrix). For example, the matrix
; [1 2 3 4
;  4 5 6 6
;  6 7 8 9 ]
; is represented as the sequence ((1 2 3 4) (4 5 6 6) (6 7 8 9)). With this representation, we can use sequence operations to 
; concisely express the basic matrix and vector operations. These operations (which are described in any book on matrix algebra) 
; are the following:
;
; (dot-product v w) returns the sum,i(v,i * w,i)
; (matrix-*-vector m v) returns the vector t, where t,i = sum,j(m,ij * v,j)
; (matrix-*-matrixm n) returns the matrix p, where p,ij = sum,k (m,ik * n,kj)
; (transpose m) returns the matrix n, where n,ij = m,ji

; We can define the dot product as:
; (define (dot-product v w)
; 	(accumulate + 0 (map * v w))) ; note: this version of map combines v and w, like zip 

; Fill in the missing expresssions in the following procedures for computing the other matrix operations. (The procedure 
; accumulate-n is defined in exercise 2.36.)

; (define (matrix-*-vector m v)
; 	(map ?? m))

; (define (transpose mat)
; 	(accumulate-n ?? ?? mat))

; (define (matrix-*-matrix m n)
; 	(let ((cols (transpose n)))
; 		(map ?? m)))

(define (matrix-*-vector m v)  ; each index in the vector is the sum of the vector zipped with that row in the matrix
	(map 
		(lambda (row)
			(accumulate 
				+ 
				0 
				(accumulate-n * 1 (list row v)))) 
		m))
1 ]=> (matrix-*-vector (list (list 2 3) (list 4 5)) (list 6 7))
;Value 10: (33 59)

(define (transpose mat)
	(accumulate-n cons (list) mat))
1 ]=> m
;Value 13: ((1 2 3) (4 5 6) (7 8 9))
1 ]=> (transpose m)
;Value 14: ((1 4 7) (2 5 8) (3 6 9))

(define (matrix-*-matrix m n)
	(let ((cols (transpose n)))
		(map 
			(lambda (row)
				(matrix-*-vector cols row))
			m)))

; These match up with wolfram alpha
1 ]=> (matrix-*-matrix (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8)))
;Value 16: ((19 22) (43 50))

1 ]=> (matrix-*-matrix (list (list 1 2 3) (list 3 4 6)) (list (list 5 6) (list 7 8) (list 11 14)))
;Value 18: ((52 64) (109 134))
