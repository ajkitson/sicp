; Suppose we evaluate teh expression (list 1 (list 2 (list 3 4))). Give the result printed by the interpreter, the corresponding box-and-
; pointer structure, and teh interpretation of this as a tree (as in figure 2.6).
; ====
; Printed by the interpreter:
1 ]=> (list 1 (list 2 (list 3 4)))
;Value 10: (1 (2 (3 4)))

; box-and-pointer (improvising the layout):

[.|.]				;(1 (2 (3 4)))
 |	\
[1]	[.|/]			
	 |
	[.|.]			; (2 (3 4))
	 |  \
	[2] [.|/]
		 |
		[.|.] 		; (3 4)
		 |  \
		[3] [.|/]
			 |
			[4]

; and as a tree:
	 .
	/ \
	1  .
	  / \
	  2  .
	  	/ \
	   3   4