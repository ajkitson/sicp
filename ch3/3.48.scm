; Explain in detail why the dealock-avoidance method described above (i.e. the accounts are numbered, and each process attempts to 
; acquire the smaller-numbered account first) avoids deadlock in the exchange problem. Rewrite serialized exchange to incorporate this idea. 
; (You will also need to modify make-account so that each account is created with a number, which can be accessed by sending an appropriate
; message)
; ======
; Why does this dealock avoidance method work? Because deadlock occurs when two processes each has a resorces that the other needs to 
; complete. By forcing an ordering on account access, we prevent this scenario. We guarantee that exchange processes will access the 
; accounts in the same order. Specifically, we guarantee that no exchange process will access the second account until it has access
; to the first. This prevents the deadlock scenario because no exchnage process can have access to the second account and not the first.
;
; To update serialized-exchange, we'll just pass the accounts to an ordering procedure and move stuff around to get serializers in order:

(define (serialized-exchange account1 account2)
    (define (order-accounts)
        (let ((account1-num (account1 'account-number))
              (account2-num (account2 'account-number)))
            (if (< account1-num account2-num)
                (cons account1 account2)
                (cons account2 account1))))
    (let ((ordered-accounts (order-accounts)))
        (let ((serializer1 ((car ordered-accounts) 'serializer))
              (serializer2 ((cdr ordered-accounts) 'serializer)))
           ((serializer1 (serializer2 exchange)) (car ordered-accounts) (cdr ordered-accounts)))))

