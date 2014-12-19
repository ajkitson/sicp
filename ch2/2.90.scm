; Suppose we want to have a polynomial system that is efficient for both sparse and dense polynomials. One way to do this is to allow
; both kinds of term-list representations in our system. The situation is analogous to the complex-number example of section 2.4, where
; we allowed both rectangular and polar representations. To do this we must distinguish different types of term lists and make the 
; operations on term lists generic. Redesign the polynomial system to implement this generalization. This is a major effort, not a 
; local change.
; =======
; To be clear, we're tagging the term-lists, not the polynomials. This will allow us to use the same procedures for all non-list 
; operators. Really, we just need to have different versions of the operations we set up in 2.89: first-term, rest-terms, adjoin-term.
; All the others we can continue to use the same (e.g. empty-termlist, etc.).
;
; Also, because the polynomial package is the only one that cares about the difference in term-list representations, we'll keep all 
; of this internal to that package.
;
; So here's what we'll do:
; - create packages for dense and sparse term-lists, each with their own versions of first-term, rest-terms, and adjoin-term
; - add generic procedure definitions in the poly package (defering to apply-generic)
; - tag the lists appropriately so we know how to minupulate them. Do this when we create the poly as that's the only time we create
; 	the list from scratch. We'll define a procedure to use a sparse list. The default make-poly will use a dense list. 
;
; This should take care of it. Let's see!
;
; Whew! I got most of it, but there were some details I wasn't anticipating. For example, in mul-terms, when we hit an empty list, 
; instead of returning the generic empty list we should return our empty list param so we retain the proper type-tag.

; Here 


; Works with dense representation:
1 ]=> a
;Value 207: (polynomial x dense (2 1) (0 5))
1 ]=> b
;Value 211: (polynomial x dense (4 2) (2 5))
1 ]=> (mul a b)
;Value 212: (polynomial x dense (6 2) (4 15) (2 25))
1 ]=> (add a b)
;Value 213: (polynomial x dense (4 2) (2 6) (0 5))


; And with the sparse represntation:
1 ]=> a
;Value 214: (polynomial x sparse 1 0 5)
1 ]=> b
;Value 215: (polynomial x sparse 2 0 5 0 0)
1 ]=> (mul a b)
;Value 222: (polynomial x sparse 2 0 15 0 25 0 0)
1 ]=> (add a b)
;Value 223: (polynomial x sparse 2 0 6 0 5)
1 ]=> (sub a b)
;Value 224: (polynomial x sparse 1 0 5)

; And mixed representations!
1 ]=> a
;Value 214: (polynomial x sparse 1 0 5)
1 ]=> b
;Value 225: (polynomial x dense (4 2) (2 5))
1 ]=> (add a b)
;Value 228: (polynomial x sparse 2 0 6 0 5)
1 ]=> (mul a b)
;Value 229: (polynomial x dense (6 2) (4 15) (2 25))







