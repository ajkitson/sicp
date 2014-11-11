; Suppose we define x and y to be two lists:
; (define x (list 1 2 3))
; (define y (list 4 5 6))

; What result is printed by the interpreter in response to evaulating each of the following expressions:
; (append x y)
; (cons x y)
; (list x y)
; =====
; I'll give some guesses and then confirm by actually running theese:
; (append x y)
; guess: (1 2 3 4 5 6)
; 
; (cons x y)
; guess: ((1 2 3) 4 5 6)
; 
; (list x y)
; guess: ((1 2 3) (4 5 6))

1 ]=> (append x y)
;Value 25: (1 2 3 4 5 6)

1 ]=> (cons x y)
;Value 26: ((1 2 3) 4 5 6)

1 ]=> (list x y)
;Value 27: ((1 2 3) (4 5 6))

