; Observe that our model of evaluation allows for combinations whose operators are compound expressions. 
; Use this observation to describe the behaviour of the following procedure
; (define (a-plus-abs-b a b)
;	 ((if (> b 0) + -) a b)))
;
; This is cool. I can use *if* to select the operator, not just the values I run through the operator!
;
; This procedure gives us a + the absolute value of b. If b > 0, then we get a + b. That's the straightforward
; case. If b <= 0, then a - b is the same as adding a + abs(b), or the positive version of b since subtracting 
; a negative is the same as adding a positive.
; 
; Again, really cool that you can handle the operators in the same way you can variables and values.