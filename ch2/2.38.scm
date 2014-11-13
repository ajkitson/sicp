; The accumulate procedure is also known as fold-right, because it combines the first element of the sequence witht the result of 
; combining all the elements to the right. There is also a fold-left, which is similar to fold-right, except that it combines elements
; working in the opposite direction:

; (define (fold-left op initial sequence)
; 	(define (iter result rest)
; 		(if (null? rest)
; 			result
; 			(iter (op result (car rest))
; 				(cdr rest))))
; 	(iter initial sequence))
;
; What are the values of
; (fold-right / 1 (list 1 2 3))
;
; (fold-left / 1 (list 1 2 3))
;
; (fold-right list (list) (list 1 2 3))
;
; (fold-left list (list) (list 1 2 3))
;
; Give a property that op should satisfy to guarentee that fold-right and fold-left will produce the same values for any sequence.
; ======
; I'll guess and verify for each of these.
; Commutivity is the property that op should satisfy for fold-left and fold-right to produce the same result. Commutivity means 
; that the order of the operands doesn't matter, e.g. a + b = b + a, or even a = b is the same as b = a
(fold-right / 1 (list 1 2 3))
; My guess: 1 / (2 / (3 / 1)) => 3/2
1 ]=> (fold-right / 1 (list 1 2 3))
;Value: 3/2

(fold-left / 1 (list 1 2 3))
; My guess (((1 / 3) / 2) / 1) => 1/6  remember that we start with the initial value!
1 ]=> (fold-left / 1 (list 1 2 3))
;Value: 1/6

(fold-right list (list) (list 1 2 3))
; My guess: (1 (2 (3)))
1 ]=> (fold-right list '() (list 1 2 3))
;Value 20: (1 (2 (3 ())))  

(fold-left list (list) (list 1 2 3))
; My guess: (3 (2 (1)))			; I got this one wrong, need to remember that the values to the left are fully evaluated. It's not just flipping l-r to be r-l. 
1 ]=> (fold-left list '() (list 1 2 3))
;Value 24: (((() 1) 2) 3)