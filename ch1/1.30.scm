; The sum procedure above generates a linear recursion. The proceudre can be rewritten so that the sum is performed iterateively. 
; Show how to do this by filling in the missing expresssions in the following definition:

(define (sum term a next b)
	(define (iter a result)
		(if (???)
			???
			(iter ??? ???)))
	(iter ?? ??))

; We just need to track our result-so-far in result and count up on a:
(define (sum term a next b)
	(define (iter a result)
		(if (> a b)
			result
			(iter (next a) (+ (term a) result))))
	(iter a 0))
