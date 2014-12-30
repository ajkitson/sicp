; Write a procedure that examines a list and determines whether it contains a cycle, that is, whether a program that tried to find the end
; of the list by taking successive cdrs would go into an infinite loop. Exercise 3.13 constructed such lists.
; =====
; What makes a cycle? First, we must encounter a pair that we've seen before. If every pair we consider is distinct, we cannot have a 
; cycle. But that's not sufficient since ex 3.16 had several structures with repeat pairs that were not cycles. A cycle was only created
; if the pair we're considering now also exists further down the cdr chain. 
;
; The obvious way to solve this is to just check whether x exists in (cdr x). This is O(n^2), but since our next exercise is to implement
; a constant time version, I assumes that's expected for now.

; This is my first shot:
(define (contains-cycle? x)
    (define (appears-again? p seq) 
        (cond 
            ((null? seq) false)    
            ((eq? p (cdr seq)) true)
            (else (appears-again  p (cdr seq)))))
    (cond 
        ((null? x) false)
        ((appears-again? x x) true)
        (else (contains-cycle? (cdr x)))))

; It works if the cycle is at the top level of a list: 
1 ]=> (define c (make-cycle (list 1 2 3)))
1 ]=> (contains-cycle? c)
;Value: #t

1 ]=> (define d (list 1 2 3))
1 ]=> (contains-cycle? d)
;Value: #f

; But if the cycle is nested in an element of the list (e.g. (car x) is a list that contains a cycle), then it doesn't find it:
1 ]=> (contains-cycle? (list d c))
;Value: #f

1 ]=> (contains-cycle? (list c d))
;Value: #f

; To get these to work, we just need to update the else clause to also check whether car x contains a cycle:
(define (contains-cycle? x)
    (define (appears-again? p seq) 
        (cond 
            ((null? seq) false)    
            ((eq? p (cdr seq)) true)
            (else (appears-again  p (cdr seq)))))
    (cond 
        ((null? x) false)
        ((appears-again? x x) true)
        (else 
            (or (contains-cycle? (cdr x))
                (if (pair? (car x))
                    (contains-cycle? (car x))
                    false)))))

; As before:
1 ]=> (contains-cycle? d)
;Value: #f
1 ]=> (contains-cycle? c)
;Value: #t

; And now it find nested cycles, too:
1 ]=> (contains-cycle? (list c d))
;Value: #t
1 ]=> (contains-cycle? (list d c 2 3 ))
;Value: #t