; Define procedures that implement the term-list representation as described above as appropriate for dense polynomials.
; =========
; For dense polynomials, we represent the term-list as a list where the elements are coefficients and the position in the list
; indicates which order term the element represents, the order being the distance from that element to the end of the list.
; For example '(6 7 8 9) corresponds to 6x^3 + 7x^2 + 8x + 9.
;
; How much do we actually have to change? Not as much as you might think. We can leave make-term along and all our higher operations
; that interact with terms don't need to know about the change. We just need to update first-term so that it returns a term that
; works with the order and coeff procedures, and we need to modify adjoin term so that it places the new term in the correct position
; on the list and rest-terms so that it drops leading zeros (though we could also just make this change in first-term). We'll leave 
; our tests to 2.90, when we update the poly package to accomodate sparse and dense representations.
; 
; We'll start with first-term and rest-terms. The key here is doing the translate to a real term with first-term, and updating
; rest-terms to skip over zeros, so that first-term always has a real term.

(define (first-term term-list)
	(make-term 
		(length (cdr term-list)) ; order = dist to end of term-list
		(car term-list)))		

(define (rest-terms term-list)
	(cond
		((null? (cdr term-list)) (the-empty-termlist))
		((= (cadr term-list) 0) (rest-terms (cdr term-list)))  ; if next elem after first = 0, skip and return rest of term-list
		(else (cdr term-list))))

; Now we'll do adjoin-term. As with the version in the text, we'll make the assumption that the term we're adding is higher
; than any other terms in the list (footnote 59), allowing us to just cons it on the front. If the order of the term is the 
; length of the rest of the list, we can just cons the coefficient to the front of the list. Otherwise we add a 0 to the 
; list and call adjoin-term until term-list is the correct length for the order of the term:
(define (adjoin-term term term-list)
	(cond 
		((=zero? (coeff term)) term-list)
		((= (order term) (length term-list))
			(cons (coeff term) term-list)))
		((> (order term) (length term-list)) 
			(adjoin-term term (cons 0 term-list)))
		(else (error "Adjoining term less than highest term in list -- SPARSE ADJOIN TERM" 
					(list term term-list)))))


