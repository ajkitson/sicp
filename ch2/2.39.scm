; Complete the following definitions of reverse (exercise 2.18) in terms of fold-right and fold-left from exercise 2.38:
;
; (define (reverse sequence)
; 	(fold-right (lambda (x y) ??) '() sequence))
;
; (define (reverse sequence)
; 	(fold-left (lambda (x y) ??) '() sequence))
; ======
(define (reverse sequence)
	(fold-right 
		(lambda (x y) (append y (list x))) 
		'() 
		sequence))

(define (reverse sequence)
	(fold-left 
		(lambda (x y) (cons y x)) 
		'() 
		sequence))

; I hadn't realized this in 2.38, but the x and y are different. In fold-left, x is the accumulated values and y is the current
; value, whereas it's the reverse in fold-right. I had understood that we were combining the values in a different order but 
; haddn't appeciated that we pass them into op in a different order, too.
