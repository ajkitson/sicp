; In section 1.2.1 we used the substitution model to analyze two procedures for computing factorials, a recursive version:

; (define (factorial n)
; 	(if (= n 1)
; 		1
; 		(* n (factorial (- n 1)))))

; and an iterative version:

; (define (factorial n)
; 	(fact-iter 1 1 n))
; (define (fact-iter product counter max-count)
; 	(if (> counter max-count)
; 		product
; 		(fact-iter (* counter product) 
; 				   (+ counter 1) 
; 				   max-count)))

; Show the environment structures created by evaluating (factorial 6) using each version of the factorial procedure.
; ===================
; We'll start out with the recursive version. Here we have the result of (define (factorial n) ...):
 ________________         
| factorial: ----|---> @ -----> parameters: n,
|________________|<--- @        body: (if (= n 1)
										  1
										  (* n (factorial (- n 1))))

; And then when we evaluate (factorial 6), we get this series of frames:
 ________________________________________________________________________
| factorial: ------------------------------------------------------------|---> @ -----> parameters: n,
|________________________________________________________________________|<--- @        body: (if (= n 1)
	   	 ^			 ^			 ^	  		 ^			 ^			 ^	 						  1
	 ____|		 ____|		 ____|		 ____|		 ____|		 ____|		  					 (* n (factorial (- n 1))))
E1->|n: 6|  E2->|n: 5|  E3->|n: 4|  E4->|n: 3|  E5->|n: 2|  E6->|n: 1|
(if (= n 1) (if (= n 1) (if (= n 1) (if (= n 1) (if (= n 1) (if (= n 1) 
    ...)        ...)        ...)        ...)        ...)        ...)    

; Now let's do the iterative version which is a bit more complicated (i.e. more involved ascii art).
; First, we have the result of (define (factorial n) ...) and (define (fact-iter product counter max-count) ...). Note that fact-iter
; is not defined within factorial so we put it in the same frame as factorial.
 ________________
| factorial: ----|---> @ -----> parameters: n,
|                |<--- @        body: (if (= n 1)
|				 | 							  1
|				 |							  (* n (factorial (- n 1))))
|				 |
| fact-iter: ----|---> @ -----> parameters: product, counter, max-count
|				 |<--- @		body: (if (> counter max-count)
|________________|					 		product
									 		(fact-iter (* counter product) 
							 				  		   (+ counter 1) 
									 				   max-count))

; And now when we evaluate (factorial 6), we get the following (omitting the definitions to save space)
 ___________________________________________________________________________________________________________________________________________________________
| 																		 																					|
|___________________________________________________________________________________________________________________________________________________________|
	   	 ^			  				^     				^     				^     				^     				^     				^     				^     
	 ____|		   	   _____________|      _____________|      _____________|      _____________|      _____________|      _____________|      _____________|      
E1->|n: 6|        E2->|product: 1   | E3->|product: 1   | E4->|product: 2   | E5->|product: 6   | E6->|product: 24  | E7->|product: 120 | E8->|product: 620 |
(fact-iter 1 1 6)	  |counter: 1   |	  |counter: 2   |	  |counter: 3   |	  |counter: 4   |	  |counter: 5   |	  |counter: 6   |	  |counter: 7   |
					  |max-count: 6 |     |max-count: 6 |     |max-count: 6 |     |max-count: 6 |     |max-count: 6 |     |max-count: 6 |     |max-count: 6 |
				  	(if (> counter       <ditto E2 for code>   
				  			max-count)
					   		 ...)



