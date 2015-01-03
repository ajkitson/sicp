; Suppose that peter, Paul, and Mary share a joint bank account that initially contains $100. Concurrently, Peter deposits $10, Paul 
; withdraws $20, and Mary withdraws half the money in the account, but executing the following commands:

; Peter: (set! balance (+ balance 10))
; Paul: (set! balance (- balance 20))
; Mary: (set! balance (- balance (/ balance 2))) ; andy: why not just (set! balance (/ balance 2))?

; a. List all the different possible values for balance after these three transactions have been completed, assuming that the banking 
; system forces the three processes to run sequentiall in some order.

; b. What are some other values that could be produced if the system allows the processes to be interleaved? Draw timing diagrams like
; the one in figure 3.29 to explain how these values can occur
; ===========
; a. The different possible balances depend on when Mary takes half the money in the account, relative to Peter and Paul's transactions:
;  Mary makes her withdrawal...
;  - Before Peter and Paul's transactions:    100 / 2 = 50, 50 + 10 - 20 = 40 
;  - After Peter and Paul's transactions:     100 + 10 - 20 = 90, 90 / 2 = 45
;  - After Peter and before Paul:  100 + 10 = 110, 110 / 2 = 55, 55 - 20 = 35
;  - After Paul and before Peter:    100 - 20 = 80, 80 / 2 = 40, 40 + 10 = 50
; 
; b. If the system allows interleaving, we can get some really weird stuff. Let's consider two cases:
; ;
; ; In this case, Paul overwrites Peter's update, and Mary's calculation gets two conflicting values for balance:
; Bank    Peter                       Paul                    Mary
; 100     access balance: 100
;                                     access balance: 100
;                                                             access balance: 100
;         new-value: 100 + 10         
;                                     new-value: 100 - 20 
;         set! balance 110
; 110
;                                                             new-value: 100 - (/ balance 2)
;                                                             access balance: 110
;                                     set! balance: 80
; 80
;                                                             new-value: 100 - (/ 110 2)
;                                                             set! balance: 45
; 45


; Bank    Peter                       Paul                    Mary
; 100                                 access balance: 100         
;                                     new-value: 100 - 20
;                                     set! balance: 80
; 80
;         access balance: 80                              
;                                                             access balance: 80
;         new-value: 80 + 10
;                                                             new-value: 80 - (/ balance 2)
;         set! balance: 90
; 90
;                                                             access balance: 90
;                                                             new-value: (80 - (/ 90 2))
;                                                             set! balance: 35
; 35




