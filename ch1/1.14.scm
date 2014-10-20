; Draw the tree illustrating the process generated by the count-change procedure of section 1.2.2 in making change for
; 11 cents. What are the orders of growth of the space and number of steps used by this process as the amount to be 
; changed increases?
; ====
; Here's the count-change procedure:

; pull highest coin available (determined by coin-types-remaining) from purse
(define (highest-coin-value coin-types-remaining) 
	(cond ((= coin-types-remaining 1) 1)
		((= coin-types-remaining 2) 5)
		((= coin-types-remaining 3) 10)
		((= coin-types-remaining 4) 25)
		((= coin-types-remaining 5) 50)))

(define (cc amount kinds-of-coins)
	(cond ((= amount 0) 1)
		((or (< amount 0) (= kinds-of-coins 0)) 0)
		(else (+ (cc (- amount 
						(highest-coin-value kinds-of-coins)) 
					kinds-of-coins)  ; assume we use the first coin and make change for the rest
				(cc amount (- kinds-of-coins 1))))))  ; all ways to make change without first type of coin

(define (count-change amount)
	(cc amount 5))

; OK, so now let's draw the tree. We'll start with kinds-of-coins = 3 so we can skip over the first
; few passes where we work down to coin denominations that make sense for 11 cents (hah!). 
; ... actually, this is a formatting challenge in text. Drew it on paper. Pretty straightforward. 

; Now let's consider growth in space and number of steps as we increase the amount to calculate change for.
; For space, we're considering the maximum depth of the tree (depth because when computing one branch of the
; tree, we need to keep track of the previous unresolved computations, but once we get to the end of the branch,
; we resolve those unresolved expressions and don't need to keep track of them anymore when we move onto the next
; branch.) 

; So, space varies linearly with the amount we're calculating change for. The longest branch is the one for which we
; compute what it'd take to change it with all pennies. That branch is n nodes deep.

; And what about steps? We can see by the general shape of the tree that the number of steps varies exponentially with
; n. If you have multiple types of coins, that is. When you have just pennies, it varies linearly--there's no real 
; branching in this case: 
; cc 11 1 >> cc 10 1 + cc 11 0. But cc 11 0 terminates immediately, so you follow cc 10 1 down to cc 0 1, with each cc X 0 
; branch terminating as soon as it starts. 
; So with just pennies, we're looking at 2n steps to complete, or O(n).
;
; Now, when we add nickles, we add a bunch of branches:
; - 1 nickel and the rest pennies (repeating that section of the all penny branch)
; - 2 nickles and the rest pennies (repeating a bit less of the all penny branch)
; - etc.
; So if before we had 2n steps, we now have n / <new denomination> new branches. Each of these new branches has between
; n / <new denomination> steps and 2(n - new denom) steps. 
; So we're looking at something less than n squared... really a constant factor of n squared.
; If we add yet another denomination, the process repeats again, with fewer new branches created the greater the new
; denomination. 
; But as n grows, the number of steps is growing at roughly the rate of n ^ (number of types of coins) * constant 
; factors that get smaller as the denomination gets larger. But contant factors don't matter here, so for five 
; denominations, we're looking at O(n^5).