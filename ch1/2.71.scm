; Suppose we have a huffman tree for an alphabet of n symbols, and that the relative frequencies of the symbols are 1, 2, 4... 2^n-1.
; Sketch the tree for n = 5 and for n = 10. In such a tree (for general n) how many bits are required to encode the most frequent
; symbol?
; ====
; Without sketching, we know that the most frequent symbol will be a leaf attached directly to the root node. This is because 
; 2^n is greater than the sum of { 1 .... 2^n - 1 }, and therefore it will always have the greatest weight of all the nodes and
; so won't be combined until we get to the root node. 
; 
; By the same logic, we know that the second most frequently used symbol will be a leaf off the second node, and so on.
;
; Now let's sketch it out:
; If n = 5, we have the following pairs (symbols are made up): (A 1) (B 2) (C 4) (D 8) (E 16)
; 
; 	( {A B C D E} 31)
;    /				\
; (E 16)		({ A B C D } 15)
;				/				\
;			(D 8)			({ A B C } 7)
;							/		   \
;						(C 4)		({ A B } 3)
;									/		\
;								(B 2)		(A 1)
;
; n = 10 is basically the same but bigger.
