; Ben Bitdiddle suggests that it's a waste of time to create a new serialized procedure in response to every withdraw and deposit message.
; He says that make-account could be changed so that the calls to protected are done outside the dispatch procedure. That is, an account 
; would return the same serialized procedure (which was created at the same time as the account) each time it is asked for a withdrawal 
; procedure. 

; (define (make-account balance pw)
;     (define (withdraw amount)
;         (if (>= balance amount)
;             (begin 
;                 (set! balance (- balance amount))
;                 balance)
;             "Insufficient funds"))
;     (define (deposit amount)
;         (set! balance (+ balance amount))
;         balance)
;     (let ((protected (make-serializer)))
;         (let ((protected-withdraw (protected withdraw))
;               (protected-deposit (protected deposit)))
;               (define (dispatch m)
;                   (cond ((eq? m 'withdraw) protected-withdraw)
;                         ((eq? m 'deposit) protected-deposit)
;                         ((eq? m 'balance) balance)
;                       (else (error "Unkown request -- MAKE-ACCOUNT" m))))
;         dispatch)))
;
; Is this a safe change to make? In particular, is there any difference in what concurrency is allowed by these two versions of 
; make-account?
; ==============
; Yep, it's safe. The important thing is that deposit and withdraw share the same serializer. Whether that serializer is added
; in dispatch or outside dispatch doesn't matter. 
; 
; To see this, consider how make-serializer might be implemented (which we haven't done yet in the book). It's probably 
; something like this:
;
; (define (make-serializer)
;     (let ((serialized-proc-running? false))
;         (lambda (p) ; serializer
;             (lambda (. args)  ; serialized version of p
;                 (if (not serialized-proc-running?)
;                     (begin
;                         (set! serialized-proc-running? true)   ; this would itself have to be serialzed somehow
;                         (apply p args)
;                         (set! serialized-proc-running? false))
;                     (< schedule for later, or don't do anything >))))))
;
; The thing to note here is that our serializer has some local state shared among all the serialized procedures that indicate whether
; a procedure in the serialized set is already running. All we need to ensure the concurrency is the same is to make sure all 
; the procedures we want to be serialized have access to this shared local state--it doesn't matter when we give it to them.

