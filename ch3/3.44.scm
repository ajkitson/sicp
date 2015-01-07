; Consider the problem of transferring an amount from one account to another. Ben Bitdiddle claims that this can be accomplished with the
; following procedure, even if there are multiple people concurrently transferring money among multiple accounts, using any account mechanism 
; that serializes deposit and withdrawal transactions, for example the version of make-account in the text above.

; (define (transfer from-account to-account amount)
;     ((from-account 'withdraw) amount)
;     ((to-account 'deposit) amount))

; Louis reasoner claims that there is a problem here, and that we need to use a more sophisticated method, such as the one rquired for deailing
; with exchange problems. Is Louis right? If not, what is the essiential difference between the transfer problem and the exchange problem?
; (You should assume that the balance in from-account is at least amount)
; =======
; Louis isn't right. We needed the more sophisticated methed for exchange because an exchange is more complex in the following way.
; An exchange is a transfer where the balances of the accounts after the exchange have been swapped. For an exchange, we need to 
; (1) determine how much to transfer, and (2) complete the transfer while the balances in both accounts are the same as were used
; to calculate. If we don't do (2), we have still completed a successful transfer but not an exchange because the balances have
; not been swapped. The method we introduced above makes sure the balances in each account don't change before the transfer is complete.
;
; A transfer is simpler. Once we know the amount to move from one account to the other, the transfer is complete once we withdraw that
; amount from the to-account and deposit it in the to-account. There doesn't need to be any coordination between the accounts during this
; time. As long as the withdrawal and deposit each complete the transfer is complete.
;