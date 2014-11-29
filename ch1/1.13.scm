; Prove that Fib(n) is the closest integer to phi^n / sqrt(5), where phi = (1 + sqrt(5)) / 2.
; Hint: let psi = (1 - sqrt(5)) / 2. Use induction and the definition of the Fibonacci number to prove that
; Fib(n) = (phi^n - psi^n) / sqrt(5)
; 
; ===
; Well, this will be fun! Haven't proved anything (mathematically) for a long time. 
;
; Let's discuss what we're trying to show here: "fib(n) is the closest integer to phi^n / sqrt(5), 
; where phi = (1 + sqrt(5)) / 2". OK, so we want to show that for any n, fib(n) is closer to phi^n / sqrt(5)
; than any other integer. What would that mean? That (abs (- fib(n) phi^n / sqrt(5))) is less than 0.5, right?.
; If it's less than 1, we know that we're less than one integer away, but the integer on the other side could still
; be closer. How do we know it's not closer? If it's on our half, or if the difference between fib(n) is less than 0.5.

; OK, now what about proving this? 
; The hint suggests using induction to show that Fib(n) = (phi^n - psi^n) / sqrt(5). Let's assume this is true and 
; show that, if this assumption holds, phi^n / sqrt(5) really is the closest integer to fib(n). 

We will prove that abs((fib(n) - (phi^n / sqrt(5))) < .5
Assume (will prove later) that Fib(n) = (phi^n - psi^n) / sqrt(5). 

We can then replace fib(n) and write: 
abs((phi^n - psi^n) / sqrt(5) - phi^n / sqrt(5)) < .5

Combine the left hand side over the common denominator and we get:
abs((phi^n - psi^n - phi^n)) / sqrt(5) < .5

Now the two phi^n cancel out and we're left with:
abs(-psi^n/sqrt(5)) < .5, 

but really we can get rid of the abs and just make psi positive:
psi^n/sqrt(5) < .5, or psi^n < sqrt(5) / 2

Now let's prove this inductively. 
Base cases:
n = 0:  1/sqrt(5) < .5, true	; psi^0 -> 1
n = 1: abs(psi) / sqrt(5) < .5 	; psi^1 -> psi
		~0.618 / sqrt(5) < .5
		~0.276 < .5

Inductive step is just to note that because psi < 1, it gets smaller as n grows larger, so if we prove n = 0 and n = 1, 
we know it holds true for every other step.

; OK, so now we know that IF we can show that fib(n) = (phi^n - psi^n) / sqrt(5) we've got this sewn up.
; Let's start with the base cases. Since we have two special base cases for Fib(n), we'll show both for the 
; phi and psi versions
Base cases: 
n = 0: 
	Fib(0) = 0 (by definition)

	(phi^0 - psi^0) / sqrt(5) = (1 - 1) / sqrt(5) 
							  = 0

n = 1:
	Fib(1) = 1 (by definition)

	(phi^1 - psi^1) / sqrt(5) = (phi - psi) / sqrt(5)
							= ((1 + sqrt(5) / 2 - (1 - sqrt(5)) / 2)) / sqrt(5)    (expand definitions of phi and psi)
							= ((1 + sqrt(5) - (1 - sqrt(5)) / 2)  ) / sqrt(5) 		(combine numerators)
							= ((2 * sqrt(5)) / 2)  ) / sqrt(5) 						(combine terms)
							= sqrt(5) / sqrt(5)				 						(combine terms)
							= 1 													(done!)

; Now that base cases are out of the way, let's do the inductive step. 
We will show that fib(n) = (phi^n - psi^n) / sqrt(5)
For n > 1, fib(n) = fib(n - 1) + fib(n + 2) 

We must therefore show that:
(phi^n - psi^n) / sqrt(5) = ((phi^(n - 1) - psi^(n-1)) / sqrt(5) 
							+ (phi^(n - 2) - psi^(n -2)) / sqrt(5))

; Let's pause and consider what we're trying to do. Now, we can see that the above relation does not hold for all numbers.
; Try it with any old a and b and you'll see it doesn't hold. So we can't just factor this, treating phi and psi
; like any other variables. That's what I did initially and wasted a TON of time. No! There must be something special
; about phi and psi for this to work. So, what is that?
; 
; A bit of googling turned this up: phi^2 = 1 + phi and psi^2 = 1 + psi. 
; I doubt I would have come up with this on my own, but confirming it is a cinch:
; (1 + sqrt(5) / 2) * (1 + sqrt(5) / 2) factors to 6 + 2(sqrt(5)) / 4, or (3 + sqrt(5)) / 2 or 1 + (1 + sqrt(5) / 2)
; You can do the same for psi on your own.
;
; Alright, now let's use this fact. Since we have phi^n-2 as part of what we're trying to prove, let's factor phi^2 our of phi^n 
; and see where that gets us
(phi^n - psi^n) / sqrt(5) = phi^2(phi^(n - 2)) - psi^2(psi^(n - 2)) / sqrt(5) 			(factoring our phi^2 and psi^2)
						  = (1 + phi)(phi^(n - 2)) - (1 + psi)(psi^(n - 2))	/ sqrt(5)	(using the fact that phi^2 = 1 + phi)
						  = phi^(n - 2) + phi^(n - 1) - (psi^(n - 2) + psi^(n - 1)) / sqrt(5)  (multiplication)
						  = (phi^(n - 2) - psi^(n - 2) / sqrt(5))
						  		+ (phi^(n - 1) - psi^(n - 1)) / sqrt(5)   (Definition of Fibonacci!)

; QED! We showed that (phi^n - psi^n) / sqrt(5) can be factored into the definition of the Fibonacci sequence

							


