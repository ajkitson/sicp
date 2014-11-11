; Consider the change-counting program of section 1.2.2. It would be nice to be able to easilt change the currency used by the program, 
; so that we could compute the number of ways to change British pound, for example. As the program is written, the knowledge of the 
; currency is distrubuted partly into the procedure first-denomination and partly into the procedure count-change (which knows that
; there are five kinds of US coins). It would be nicer to be able to supply a list of coins to be used for making change.

; We want to reqrite the procedure cc so that its econd argument is a list of the values of the coins to use rather than an interger 
; specifying which coins to use. We could then have lists that defined each kind of currency:
; (define us-coins (list 50 25 10 5 1))
; (define uk-coins (list 100 50 25 10 5 2 1 0.5))

; We could then call cc as follows:
; (cc 100 us-coins)

; To do this will require changing the program cc somewhat. It will still have the same form, but it will access its second
; argument differently, as follows:

(define (cc amount coin-values)
	(cond ((= amount 0) 1)
		((or (< amount 0) (no-more? coin-values)) 0)
		(else 
			(+ (cc amount
					(except-first-denomination coin-values))
				(cc (- amount (first-denomination coin-values)) 
					coin-values)))))

; Define the procedures first-denomination, except-first-denomination, and no-more? in terms of primitive operations on list 
; structures. Does the order of the list coind-values affect the answer produced by cc? Why or why not?
(define (first-denomination coins)
	(car coins))

(define (except-first-denomination coins)
	(cdr coins))

(define (no-more? coins)
	(null? coins))

1 ]=> (cc 100 (list 50 25 10 5 1))
;Value: 292

; Does the order of the list matter? Nope. Because we're trying all combinations of the values in the list until they either equal
; the value we're looking for or go over. It doesn't need to work through the list in any particular order. As long as the order
; doesn't change once we call cc (except for popping values off the front)