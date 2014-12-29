; Devise a correct version of the count-pairs procedre of exercise 3.16 that returns the number of distinct pairs in any structure. (Hint:
; Traverse the structure, maintaining an auxiliary data structure that is used to keep track of which pairs have already been counted.)
; =======
; I see two main challenges: (1) determining whether we've seen a given pair before, and (2) not falling into cycles. Though actually, 
; solving (1) allows us to solve (2), in that if we have a pair we've seen before, not only do we not count it, we don't follow it to 
; find new pairs. 
;
; We can use eq? to compare pairs (since it looks at memory location and will recognize when we're considering the same structure without
; having to compare elements). We'll start by just storing the pairs in a list as we count them and then checking against that list. 
; Since we don't want the list hanging around outside count-pairs, but we do want the same list to be avaiable on each recursive call
; to count-pairs, we'll take the body of count-pairs and stuff it in an internal procedure.

(define (count-pairs x)
    (let ((pair-list '(afadfafd)))
        (define (seen-before? x)
            (any (lambda (p) (eq? p x)) pair-list))
        (define (add-to-list x)
            (append! pair-list (list x)))
        (define (count-pairs-internal x)
            (cond 
                ((not (pair? x)) 0)
                ((seen-before? x) 0)
                (else 
                    (add-to-list x)
                    (+ (count-pairs (car x))
                       (count-pairs (cdr x))
                       1))))
    (count-pairs-internal x)))

; Now let's see how this works against the structures Ben's procedure had issues with.
; We get 3 for the standard case:
1 ]=> (count-pairs (list 1 2 3))
;Value: 3

; And we don't fall into the cycle:
1 ]=> (define a (make-cycle (list 1 2 3)))
1 ]=> (count-pairs a)
;Value: 3

; And it picks up on pairs being re-used within a structure:
1 ]=> (define a (list 'a))
1 ]=> (count-pairs (cons 'b (cons a a)))
;Value: 3

1 ]=> (define a (list 1))
1 ]=> (define b (cons a a))
1 ]=> (define c (cons b b))
1 ]=> (count-pairs c)
;Value: 3

