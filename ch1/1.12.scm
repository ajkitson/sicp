; The following pattern of numbers is called Pascal's triangle:
; 0           1
; 1          1 1
; 2         1 2 1
; 3        1 3 3 1
; 4       1 4 6 4 1
; 5     1 5 10 10 5 1
; 6    1 6 15 20 15 6 1
; 7   1 7 21 35 35 21 7 1
; ...
; The numbers at the edge are all 1 and each number inside is the sum of the two numbers above it. Write a procedure
; that computes elements of Pascal's triangle by means of a recursive process
;
; ====
; Let's start by thinking how values are generated, given a row and an index in that row (zero-based index):
; if ix = 0 or ix = row number, then val = 1
; otherwise, val = val(row - 1, ix -1) + val(row - 1, ix)

(define (pascal-val row ix)
	(if (or (= ix 0)
			(= ix row))
		1
		(+ (pascal-val (- row 1) (- ix 1))
			(pascal-val(- row 1) ix)))))

1 ]=> (pascal-val 6 3)
;Value: 20

1 ]=> (pascal-val 7 7)
;Value: 1

1 ]=> (pascal-val 7 6)
;Value: 7

1 ]=> (pascal-val 7 5)
;Value: 21

1 ]=> (pascal-val 7 4)
;Value: 35
