; The encode precedure takes as arguments a message and a tree and produces the list of bits that gives the encoded message. 
; 
; (define (encode message tree)
; 	(if (null? message)
; 		'()
; 		(append (encode-symbol (car message) tree)
; 			(encode (cdr message) tree))))

; Encode-symbol is a procedure, which you must write, that returns the list of bits that encodes a given symbol according to a given 
; tree. You should design encode-symbol so that it signals an error if the symbol is not in the tree at all. Test your procedure by 
; encoding the result you obtained in exercise 2.67 with the sample tree and seeing whether it is the same as the original sample
; message.
; ===
; encode-symbol just needs to traverse the tree until we find the symbol and record the choices it makes (left or right branch)
; along the way. We start with a tree and check whether the left branch contains the symbol. We encode a 0 if it does. If the 
; left branch is a leaf, we're done, otherwise we call encode-symbol recursively, passing the left branch as a tree. If the left
; branch contains the symbol, we perform the same procedure on the right branch. If neither branch contains the symbol, we 
; return an error.

(define (encode-symbol symbol tree)
	(cond 
		((and (leaf? tree) (equal? (symbol-leaf tree) symbol)) ; base case: found the leaf with the symbol: we're done!
			'())
		((symbol-on-branch symbol (left-branch tree))
			(cons 0 (encode-symbol symbol (left-branch tree))))
		((symbol-on-branch symbol (right-branch tree))
			(cons 1 (encode-symbol symbol (right-branch tree))))
		(else (error "Symbol not in tree!"))))

(define (symbol-on-branch symbol branch)
	(define (belongs-to-set symbol set)  ; simple check on set as unordered list
		(cond 
			((null? set) false)
			((equal? symbol (car set)) true)
			(else (belongs-to-set symbol (cdr set)))))
	(belongs-to-set symbol (symbols branch)))


; Here it is in action:
1 ]=> sample-message
;Value 2: (0 1 1 0 0 1 0 1 0 1 1 1 0)
1 ]=> (encode (decode sample-message sample-tree) sample-tree)
;Value 6: (0 1 1 0 0 1 0 1 0 1 1 1 0)

; Throwing an error when given a symbol not in the tree:
1 ]=> (encode '(a d a b w c a) sample-tree)
;Symbol not in tree!

