; Suppose that the balances in three accounts start out as $10, $20, and $30, and that mulitple processes run, exchanging the balances in
; the accounts. Argue that if the processes are run sequentially , after any number of concurrent exchanges the account balances should be 
; $10, $20, and $30 in some order. Draw a timing diagram like the one in figure 3.29 to show how this condition can be violated. if the 
; exchanges are implemented using the first version of the account-exchange program in this section. On the other hand, argue that even
; with this exchange program, the sum of the balances in the accounts will be preserved. Draw a timing diagram to show how even this 
; condition would be violated if we did not serialize the transaction on individual accounts.
; =====
; If we run exchange processes sequentially, the balances will always be $10, $20, and $30 in some order. This is because an exchange is 
; simply swapping the balances in two accounts. If we run them sequentially, then we do not begin a new exchange until the previous 
; exchange has completed. You can see be induction that sequential swaps can change which accounts have which value, but never the 
; values themselves. If we start with accounts that have $10, $20, and $30 dollars and perform one swap, then one account will have
; the value it had prior to the swap and two accounts will have switched values. If we perform another swap, the same thing happens.
; Because we return to our basic starting point after each swap (accounts with $10, $20, and $30, if not in the same order), if any
; one swap does not alter the values we can conclude the no number of swaps will alter the values.
;
; But that changes if we allow the swapping processes to interleave. Consider this diagram where a swap between accounts A and B 
; overlaps with a swap between accounts B and C:

Balances:      Exchange steps:
A   B   C      Swap A and B:            Swap B and C:
30  20  10    
               Retrieve A balance: 30
               Retrieve B balance: 20
               Calculate difference: 10
                                        Retrieve B balance: 20
                                        Retrieve C balance: 10
                                        Calculate difference: 10
               Account A: withdraw 10
20
               Account B: deposit 10
    30                                  
                                        Account B: withdraw 10
    20
                                        Account C: deposit 10
        20                                        
20  20  20

; Above we have a scenario where all accounts end up with $20. This isn't correct, but note that the account balances will always add
; up to $60 (total balance value will be conserved among accounts participating in the exchanges). This is because the source of 
; concurrency error is when the balance on an account changes in the time between when it is used to calculate the amount to be 
; exchanged and the time when the exchange is actually performed. It is impossible for this type of discrepency to change the overall
; total. 
;
; Why? Because the exchange always adds and subtracts the same amount from each side of the exchange. It does not introduce any money 
; to the system or remove it. If the balance on one or both sides of the transaction has changed since the difference between accounts 
; was calculated, well, then the transaction might not count as an exchange. But (stipulating that the balance must have changed 
; due to an exchange where we add the same amount to one account that we add to the other), we still have the same amount of money among
; all accounts participating in exchanges. If no one transaction can introduce new money into the system or take it out, then no number 
; of such transactions will change the overall total.
;
; If we introduce transactions where the withdrawals and deposits might not be balanced (as in unserialized deposits and withdrawals), 
; we introduce the possiblity that the total amount of money might change.
;
; Consider just two accounts:
A    B    C   Exchange steps:
30   20   10  Swap A and B                Swap B and C
              Retrieve A balance: 30
              Retrieve B balance: 20
              Calculate difference: 10
                                          Retrieve B balance: 20
                                          Retrieve C balance: 10
                                          Calculate difference: 10
             Account A: withdraw 10       
20           Account B: deposit 10                  
                 deposit gets balance
                 to increment: 20
                                        Account B: withdraw 10  
                                            withdraw gets balance 
                                            to decrement: 20
                                            withdraw sets balance to 20 - 10
    10
                deposit sets balance
                to 20 + 10
    30              
                                        Account C: deposit 10
        20
20 30 20

; The above, where A/B swap overwrites the B value from the B/C swap, shows that if our withdraw and deposit operations are not serialized
; we can change the total amount in the system.











