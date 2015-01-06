; Louis Reasoner thinks our bank account system is unnecessarily complex and error prone now that deposits and withdrawals aren't automatically
; serialized. He suggests that make-account-and-serializer should have exported the serializer in addition to (rather than instead of) 
; using it to serialize accounts and deposits as make-account did. He proposes to redefine accounts as follows:

; (define (make-account-and-serializer balance pw)
;     (define (withdraw amount)
;         (if (>= balance amount)
;             (begin 
;                 (set! balance (- balance amount))
;                 balance)
;             "Insufficient funds"))
;     (define (deposit amount)
;         (set! balance (+ balance amount))
;         balance)
;     (let ((balance-serializer (make-serializer)))
;         (define (dispatch m)
;             (cond ((eq? m 'withdraw) (balance-serializer withdraw))
;                   ((eq? m 'deposit) (balance-serializer deposit))
;                   ((eq? m 'balance) balance)
;                   ((eq? m 'balance-serializer) balance-serializer)
;                   (else (error "Unkown request -- MAKE-ACCOUNT" m))))
;     dispatch)))

; Then deposits are handled as with the original make-account:
; (define (deposit account amount)
;     ((account 'deposit) amount))

; Explain what is wrong with Louis' reasoning. In particular, consider what happens when serialized-exchange is called
; ========
; The issue is any procedure that using the exposed serializer on it's own cannot use the deposit and withdraw procedures because
; they also use the serializer. serialized-exchange exchange is one example of a procedure that would have issues. I'd think that
; almost anything you'd write where you would want to use the exposed serializer will run into this issue to.
;
; Here's the issue. When we use the balance-serializer in serialized-exchange, we basically say "no other procedure that uses this
; serializer can run until our exchange procedure completes". But if we serialize deposit and withdraw internal to make-account, Then
; neither of them can complete until exhcnage complets. However exhcange cannot complete without deposit and withdraw completing,
; giving us a sort of deadlock.