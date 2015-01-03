; Ben Bitdiddle worries that it would be better to implement the bank account as follows (where the commented line has been changed):

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
;         (define (dispatch m)
;             (cond ((eq? m 'withdraw) (protected withdraw))
;                   ((eq? m 'deposit) (protected deposit))
;                   ((eq? m 'balance) 
;                     (protected (lambda () balance)))
;                   (else (error "Unkown request -- MAKE-ACCOUNT" m))))
;         dispatch))
;
; because allowing unserialized access to the bank balance can result in anamolous behavior. Do you agree? Is there any scenario that
; demonstrates Ben's concern?
; ==========
; I don't agree. Serializing makes sure that references to the same variable remain consistent within the serialized expression by 
; preventing other expression using the same serializer from updating them. But if there's only one reference to balance, there's nothing
; that needs to remain consistent.
;
; The only case I can see Ben's concern playing out is if looking up balance is not an atomic operation. Say, if we could start to retrieve
; balance and in the middle of it some other operation sets it and changes whatever the unread portion of balance is, giving us a 
; messed up value--not just wrong, but possibly nonsense.
; 
; But if that were an issue, we'd be in major trouble with any mutable shared state. ...right??