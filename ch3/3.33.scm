; Using primitive multiplier, adder, and constant constraints, define a procedure averager that takes three connectors a, b, and c as inputs
; and establishes the constraint that the value of c is the average of the values of a and b.
; ==========
; Cool! We'll finally get some of this stuff up and working--actually try it out.
;
; I'll define the averager first, and then go back and cobble together a package so we can see it work.
; 
; The definitions of process-forget-value and m are basically the same as adder and multiplier. It's really just process-new-value that's
; different. 
;

(define (averager a b c)
    (define (compute-other-val a c)
        (- (* 2 c) a))
    (define (process-new-value)
        (cond ((and (has-value? a) (has-value? b))
                (set-value! c 
                            (/ (+ (get-value a) (get-value b))
                                2)
                            me))
              ((and (has-value? a) (has-value? c))
                (set-value! b
                            (compute-other-val (get-value a) (get-value c))
                            me))
              ((and (has-value? b) (has-value? c))
                (set-value! a
                            (compute-other-val (get-value b) (get-value c))
                            me))))
    (define (process-forget-value)
        (forget-value! c me)
        (forget-value! a me)
        (forget-value! b me)
        (process-new-value))
    (define (me request)
        (cond ((eq? request 'I-have-a-value)
                (process-new-value))
              ((eq? request 'I-lost-my-value)
                (process-forget-value))
              (else 
                (error "Unknown request -- AVERAGER" request))))
    (connect a me)
    (connect b me)
    (connect c me)
    me)

; I can't believe this worked on the first shot!
; We can define connectors and a constraint:
1 ]=> (define a (make-connector))
1 ]=> (define b (make-connector))
1 ]=> (define c (make-connector))
1 ]=> (define av (averager a b c))

; Set the value an a and b, and we automatically get a value in c:
1 ]=> (set-value! a 6 'andy)
;Value: done
1 ]=> (set-value! b 18 'andy)
;Value: done
1 ]=> (get-value c)
;Value: 12

; If we try to set the value in c now, it won't let us:
1 ]=> (set-value! c 30 'andy)
;Contradiction! (12 30)
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.
2 error> 
;Quit!


; But if we forget the value in a or b, we can set a value for c and see the connector we cleared get a new value:
1 ]=> (forget-value! b 'andy)
;Value: done
1 ]=> (set-value! c 30 'andy)
;Value: done
1 ]=> (get-value b)
;Value: 54
1 ]=> (get-value a)
;Value: 6
1 ]=> (get-value c)
;Value: 30
