; Ben Bitdiddle tells Louis that one way to avoid the trouble in exercise 3.34 is to define a squarer as a new primitive constraint. Fill in
; the missing portions in Ben's outline for a procedure to implement such a constraint.
; =====
; Just had to fill in process-new-value to set a to sqrt of b if we have a value for b and set b to a squared if we have a value for a.
; I forgot to check (has-value? a) before setting b the first time around, which caused issues when I tried to forget values (for a or b).
; Beacuse we weren't checking if a was set (had an informant), but just grabbing the value, we would grab the most recent value, even if
; it should have been forgotten, and then set b to it's square. So we could never really forget values once set. Easy enough to fix once 
; I saw what was happening.

(define (squarer a b)
    (define (process-new-value)
        (if (has-value? b)
            (if (< (get-value b) 0)
                (error "square less than 0 -- SQUARER" (get-value b))
                (set-value! a (sqrt (get-value b)) me))
            (if (has-value? a)
                (let ((a-val (get-value a)))
                    (set-value! b (* a-val a-val) me)))))
    (define (process-forget-value)
        (forget-value! a me)
        (forget-value! b me)
        (process-new-value))
    (define (me request)
        (cond ((eq? request 'I-have-a-value)
                (process-new-value))
              ((eq? request 'I-lost-my-value)
                (process-forget-value))
              (else 
                (error "Unknown request -- SQUARER" request))))
    (connect a me)
    (connect b me)
    me)

; In action:
1 ]=> (Define a (make-connector))
1 ]=> (Define b (make-connector))
1 ]=> (define s (squarer a b))
1 ]=> (set-value! a 13 'andy)
;Value: done
1 ]=> (Get-value b)
;Value: 169
1 ]=> (forget-value! a 'andy)
;Value: done
1 ]=> (has-value? b)
;Value: #f
1 ]=> (set-value! b '144 'andy)
;Value: done
1 ]=> (Get-value a)
;Value: 12
