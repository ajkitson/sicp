; The procedure square-list takes a list of numbers as argument and returns a list of the squares of those numbers.
; (square-list (list 1 2 3 4))
; (1 4 9 16)

; Here are two different definitions of square-list. Complete both of them by filling in the missing expressions:
; (define (square-list items)
; 	(if (null? items)
; 		(list)
; 		(cons <??> <??>)))

; (define (square-list items)
; 	(map <??> <??>))

(define (square-list items)
	(if (null? items)
		(list)
		(cons 
			(square (car items)) 
			(square-list (cdr items)))))

1 ]=> (square-list (list 1 2 3 4 5 6))
;Value 8: (1 4 9 16 25 36)

(define (square-list items)
	(map square items))

1 ]=> (square-list (list 1 2 3 4 5 6))
;Value 9: (1 4 9 16 25 36)