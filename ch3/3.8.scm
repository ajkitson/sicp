; When we defined the evaluation model in section 1.1.3, we said that the first step in evaluating an expression is to evaluate its
; subexpressions. But we never specified the order in which the subexpressions should be evaluated (e.g. left to right or right to left).
; When we introduce assignment, the order in which the arguments to a procedure are evaluated can make a difference to the result.
; Define a simple procedure f such that evaluating (+ (f 0) (f 1)) will return 0 if the arguments to + are evaluated left to right
; but will return 1 if the arguments are evaluated right to left.
; =======
; I was wondering about this earlier and figured it out by running (list (display "left") (display "right"))
; 1 ]=> (list (display "left") (display "right"))
; rightleft
;
; We'll just define f to return it's argument the first time it is called and zero otherwise
(define f
	(let ((invoked false))
		(lambda (n)
			(if invoked
				0
				(begin
					(set! invoked true)
					n)))))


; And it's right to left:
1 ]=> (+ (f 0) (f 1))
;Value: 1

; If we reset f and reverse the args to +, we get 0, again showing right to left eval
1 ]=> (+ (f 1) (f 0))
;Value: 0