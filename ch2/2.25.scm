; Give combinations of cars and cdrs that will pick 7 from each of the following lists:
; (1 3 (5 7) 9)
; ((7))
; (1 (2 (3 (4 (5 (6 7))))))


1 ]=> (define l (list 1 3 (list 5 7) 9))
1 ]=> (car (cdr (car (cdr (cdr l)))))
;Value: 7

1 ]=> (define l (list (list 7)))
1 ]=> (car (car l))
;Value: 7

1 ]=> (define l (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))
1 ]=> (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr l))))))))))))
;Value: 7

; This exercise and the previous one (esp box-and-pointer diagram) really drive home that the cdr is a list, even if it's just
; one element. Hadn't quite appreciated that before.
