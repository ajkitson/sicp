; In the make-withdraw procedure, the local variable balance is created as a parameter of make-withdraw. We could also create the local
; state variable explicitly, using let, as follows:

; (define (make-withdraw initial-amount)
; 	(let ((balance initial-amount))
; 		(lambda (amount)
; 			(if (>= balance amount)
; 				(begin (set! balance (- balance amount))
; 					balance)
; 				("Insufficient funds")))))

; Recall from section 1.3.2 that let is simply syntactic sugar for a procedure call:
; (let ((<var> <exp>)) <body>)
; is interpreted as an alternate syntax for
; ((lambda (<var>) <body>) <exp>)

; Use the environment model to analyze this alternate version of make-withdraw, drawing figures like the ones above to illustrate the 
; interactions:
; (define W1 (make-withdraw 100))
; (W1 50)
; (define W2(make-withdraw 100))

; Show that the two versions of make-withdraw create objects with the same behavior. How do the environment structures differ in the
; two versions?
; ======
; The main difference is that W1 and W2 are one more step removed from the global environment in the version that uses let. 
; Before we had E1 and E2 created to hold the value for balance specific to W1 and W2. Now E1 and E2 will each enclose another
; environment created when we evaluate let (because evaluating let is really evaluating a lambda). These E1 and E2 contain the
; value of initial-amount specific to W1 and W2, and now the new environments contain the value of balance specific to W1 and
; W2.
;
; Here's the make-withdraw definition:
 ______________________
| make-withdraw: ------|--> @ -----------> parameters: initial-amount
|______________________|<-- @ (env ptr)	   body: (let ((balance initial-amount))
											 		(lambda (amount)
														(if (>= balance amount)
															(begin (set! balance (- balance amount))
																balance)
															("Insufficient funds"))))


; And now when we define W1, we get a bit more complicated of a setup:
 _______________________
| make-withdraw: -------|--> @ -----------> parameters: initial-amount
|					    |<-- @ (env ptr)		  body: (let ((balance initial-amount))
|					    |							 		(lambda (amount)
|					    |										(if (>= balance amount)
|						|											(begin (set! balance (- balance amount))
|						|												balance)
|						|											("Insufficient funds"))))
|						|
| W1:-------------------| --> @ ----------> parameters: amount
|_______________________|	  @					  body: (lambda (amount)
				   ^     	  |	  							(if (>= balance amount)
 __________________|	   	  |									(begin (set! balance (- balance amount))
|initial-amount:100|(created  |										balance)
|__________________|  by let) |									("Insufficient funds")))
				   ^    	  |
 __________________|		  |												
|balance: 100      | <--------|	
|__________________| (created by lambda)


; OK, now let's evaluate (W1 50). Basically, we create a frame to hold amount:50, with E2 as it's enclosing environment. We'll 
; look at a during and after picture (omitting the make-withdraw part, which doesn't change).
; Here's what happens during the (W1 50) evaluation:
 _______________________
| W1:-------------------| --> @ ----------> parameters: amount
|_______________________|	  @					  body: (lambda (amount)
				   ^     	  |	  							(if (>= balance amount)
 __________________|	   	  |									(begin (set! balance (- balance amount))
|initial-amount:100|(created  |										balance)
|__________________|  by let) |									("Insufficient funds")))
				   ^    	  |
 __________________|		  |												
|balance: 100      | <--------|	
|__________________| (created by lambda)
				   ^
 __________________|
|amount: 50        | 
|__________________| (created by (W1 50) call) (if (>= balance amount)...)

; And here is after, with balance changed and the environment created for (W1 50) gone since nothing points at it anymore:
 _______________________
| W1:-------------------| --> @ ----------> parameters: amount
|_______________________|	  @					  body: (lambda (amount)
				   ^     	  |	  							(if (>= balance amount)
 __________________|	   	  |									(begin (set! balance (- balance amount))
|initial-amount:100|(created  |										balance)
|__________________|  by let) |									("Insufficient funds")))
				   ^    	  |
 __________________|		  |												
|balance: 50       | <--------|	
|__________________| (created by lambda)


; And finally, when we create W2 by evaluating (define W2 (make-withdraw 100)). We'll diagram W1 and W2 as sharing the same code, 
; but as noted in footnote 15, whether they share the same physical code is an implementation detail of the interpreter.


 __________________ 
|balance: 100	   |(created by lambda)
|__________________| <--------|	 
	|			     		  |  	 
 ___|______________		 	  |
|initial-amount:100| (created |
|__________________|  by let) |
	|						  |
 ___|___________________	  |
| W2:-------------------| --> @
|						|	  @ --------|
|						|				|	   
|						|				|		
| W1:-------------------| --> @ ----------> parameters: amount
|_______________________|	  @					  body: (lambda (amount)
				   ^     	  |	  							(if (>= balance amount)
 __________________|	   	  |									(begin (set! balance (- balance amount))
|initial-amount:100|(created  |										balance)
|__________________|  by let) |									("Insufficient funds")))
				   ^    	  |
 __________________|		  |												
|balance: 50       | <--------|	
|__________________| (created by lambda)



