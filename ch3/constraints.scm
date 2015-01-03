(define (inform-about-value constraint)
    (constraint 'I-have-a-value))
(define (inform-about-no-value constraint)
    (constraint 'I-lost-my-value))

(define (for-each-except exception procedure items)
    (define (loop items)
        (cond 
            ((null? items) 'done)
            ((eq? (car items) exception) (loop (cdr items)))
            (else 
                (procedure (car items))
                (loop (cdr items)))))
    (loop items))

(define (has-value? connector)
    (connector 'has-value?))
(define (get-value connector)
    (connector 'value))
(define (set-value! connector new-val informant)
    ((connector 'set-value!) new-val informant))
(define (forget-value! connector retractor)
    ((connector 'forget) retractor))
(define (connect connector new-constraint)
    ((connector 'connect) new-constraint))

(define (make-connector)
    (let ((value false) (informant false) (constraints '()))
        (define (set-my-value newval setter)
            (cond 
                ((not (has-value? me))
                    (set! value newval)
                    (set! informant setter)
                    (for-each-except setter
                                     inform-about-value
                                     constraints))
                ((not (= value newval))
                    (error "Contradiction!" (list value newval)))
                (else 'ignored)))
        (define (forget-my-value retractor)
            (if (eq? retractor informant)
                (begin
                    (set! informant false)
                    (for-each-except retractor
                                     inform-about-no-value
                                     constraints))
                'ignored))
        (define (connect new-constraint)
            (if (not (memq new-constraint constraints))
                (set! constraints (cons new-constraint constraints)))
            (if (has-value? me)
                (inform-about-value new-constraint)))
        (define (me request)
            (cond 
                ((eq? request 'has-value?)
                    (if informant true false))
                ((eq? request 'value) value)
                ((eq? request 'set-value!) set-my-value)
                ((eq? request 'forget) forget-my-value)
                ((eq? request 'connect) connect)
                (else (error "Unknown operations -- CONNECTOR" request))))
        me))



;; CONSTRAINTS
(define (adder a b c)
    (define (process-new-value)
        (cond ((and (has-value? a) (has-value? b))
                (set-value! c 
                            (+ (get-value a) (get-value b))
                            me))
              ((and (has-value? a) (has-value? c))
                (set-value! b
                            (- (get-value c) (get-value a))
                            me))
              ((and (has-value? b) (has-value? c))
                (set-value! a
                            (- (get-value c) (get-value b))
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
                (error "Unknown request -- ADDER" request))))
    (connect a me)
    (connect b me)
    (connect c me)
    me)


(define (multiplier a b c)
    (define (process-new-value)
        (cond ((and (has-value? a) (has-value? b))
                (set-value! c 
                            (* (get-value a) (get-value b))
                            me))
              ((and (has-value? a) (has-value? c))
                (set-value! b
                            (/ (get-value c) (get-value a))
                            me))
              ((and (has-value? b) (has-value? c))
                (set-value! a
                            (/ (get-value c) (get-value b))
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
                (error "Unknown request -- ADDER" request))))
    (connect a me)
    (connect b me)
    (connect c me)
    me)

(define (divider a b c)
    (define (process-new-value)
        (cond ((and (has-value? a) (has-value? b))
                (set-value! c 
                            (/ (get-value a) (get-value b))
                            me))
              ((and (has-value? a) (has-value? c))
                (set-value! b
                            (* (get-value c) (get-value a))
                            me))
              ((and (has-value? b) (has-value? c))
                (set-value! a
                            (* (get-value c) (get-value b))
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
                (error "Unknown request -- ADDER" request))))
    (connect a me)
    (connect b me)
    (connect c me)
    me)



(define (constant value connector)
    (define (me request)
        (error "Unknown request -- CONSTANT" request))
    (connect connector me)
    (set-value! connector value me)
    me)


(define (averager a b c)
    (let ((sum (make-connector))
          (half (make-connector)))
        (adder a b sum)
        (constant 0.5 half)
        (multiplier sum half c)))

; (define (averager a b c)
;     (define (compute-other-val a c)
;         (- (* 2 c) a))
;     (define (process-new-value)
;         (cond ((and (has-value? a) (has-value? b))
;                 (set-value! c 
;                             (/ (+ (get-value a) (get-value b))
;                                 2)
;                             me))
;               ((and (has-value? a) (has-value? c))
;                 (set-value! b
;                             (compute-other-val (get-value a) (get-value c))
;                             me))
;               ((and (has-value? b) (has-value? c))
;                 (set-value! a
;                             (compute-other-val (get-value b) (get-value c))
;                             me))))
;     (define (process-forget-value)
;         (forget-value! c me)
;         (forget-value! a me)
;         (forget-value! b me)
;         (process-new-value))
;     (define (me request)
;         (cond ((eq? request 'I-have-a-value)
;                 (process-new-value))
;               ((eq? request 'I-lost-my-value)
;                 (process-forget-value))
;               (else 
;                 (error "Unknown request -- AVERAGER" request))))
;     (connect a me)
;     (connect b me)
;     (connect c me)
;     me)

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



;; EXPRESSION ORIENTED STYLE PROCS
(define (c+ x y)
    (let ((z (make-connector)))
        (adder x y z)
        z))

(define (c* x y)
    (let ((z (make-connector)))
        (multiplier x y z)
        z))

(define (c/ x y)
    (let ((z (make-connector)))
        (divider x y z)
        z))

(define (c- x y)
    (let ((z (make-connector))
          (m (make-connector)))
        (multiplier y (cv -1) m) ; m is y * -1
        (adder x m z)
        z))

(define (cv val)
    (let ((z (make-connector)))
        (constant val z)
        z))



;; Set up some variables to test with
(define a (make-connector))
(define b (make-connector))
(define c (make-connector))
