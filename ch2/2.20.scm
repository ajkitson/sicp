; The procedures +, *, and list take arbitrary numbers of arguments. One way to define such procedures is to use define with dotted-tail
; notation. In a procedure definition, a parameter list that has a dot before the last parameter name indicates that, when the proceudre 
; is called, the initial parameters (if any) will have as values the initial arguments, as usual, but the final parameter's value will
; be a list of any remaining arguments. For instance, given the definition (define (f x y .z ) <body>) the procedure f can be called
; with two or more arguments. If we evaluate (f 1 2 3 4 5) then in the body of f, x will be 1, y will be 2, and z will be the list
; (3 4 5). Given the definition (define (g . w) <body>) the procedure g can be called with zero or more arguments. If we evaluate
; (g 1 2 3 4 5), then in the body of g, w will be the list (1 2 3 4 5). 

; Use this notation to write a procedure same-parity that takes one or more integers and returns a list of all the arguments that have
; the same even-odd parity as the first arguments. For example, 
; (same-parity 1 2 3 4 5 6 7)
; (1 3 5 7)
; (same-parity 2 3 4 5 6 7)
; (2 4 6)
; ====
; Hmmm. Let's use this as an opportunity to make a generic filter function and then use that to define same-parity.
(define (filter fn items)
	(if (null? items)
		(list)
		(let ((pass (fn (car items))))
			 (if (not pass)
			 	(filter fn (cdr items))
			 	(cons
			 		(car items)
			 		(filter fn (cdr items)))))))

(define (same-parity . nums)
	(filter 
		(lambda (n)
			(if (= (remainder (car nums) 2) (remainder n 2))
				true
				false))
		nums))

; here it is in action:
1 ]=> (same-parity 51 60 32 2 3 4 5 87 92)
;Value 13: (51 3 5 87)

1 ]=> (same-parity 50 60 32 2 3 4 5 87 92)
;Value 14: (50 60 32 2 4 92)


