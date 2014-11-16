; What would the interpreter print in evaluating the following expressions?
; (list 'a 'b 'c)
; (list (list 'george))
; (cdr '((x1 x2) (y1 y2)))
; (cadr '((x1 x2) (y1 y2)))
; (pair? (car '(a short list)))
; (memq 'red '((red shoes) (blue socks)))
; (memq 'red '(red shoes blue socks))
; =====
; I'll do my guesses and then run them

(list 'a 'b 'c)
; my guess: (a b c), because we print a list of the symbols a, b, and c
1 ]=> (list 'a 'b 'c)
;Value 5: (a b c)

(list (list 'george))
; my guess: ((george)), because we have a list that contains the symbol george nested in another list
1 ]=> (list (list 'george))
;Value 6: ((george))


(cdr '((x1 x2) (y1 y2)))
; My guess: ((y1 y2)). This doesn't feel quite right, but lines up with the examples. There are two things I'm wondering about: does
; the quote apply to the elements in the list (the two nested lists and x1, x2, y1, and y2)? And does cdr operate no the quoted list
; in the same way that it operates on a list expression? For ((y1 y2)) to be correct, the quote must apply to all the elements 
; of the outer list, and cdr must treat it the same as a list expression. Let's see:
1 ]=> (cdr '((x1 x2) (y1 y2)))
;Value 7: ((y1 y2))
; And I'm right! 

(cadr '((x1 x2) (y1 y2)))
; My guess: (y1 y2). Because this is the same as above, except we're taking the car of the cdr, so we strip the outer list from
; the results
1 ]=> (cadr '((x1 x2) (y1 y2)))
;Value 8: (y1 y2)

(pair? (car '(a short list)))
; My guess: false. (car '(a short list)) is going to be a, which is not a pair
1 ]=> (pair? (car '(a short list)))
;Value: #f

(memq 'red '((red shoes) (blue socks)))
; My guess: false, because memq doesn't search within nested lists, just comparing the outer symbols
1 ]=> (memq 'red '((red shoes) (blue socks)))
;Value: #f

(memq 'red '(red shoes blue socks))
; My guess: true, because 'red is now a top level element of the list memq operates on
1 ]=> (memq 'red '(red shoes blue socks))
;Value 10: (red shoes blue socks)
; Ah! got this wrong. We found 'red, but we return the list after red instead of just true or false

