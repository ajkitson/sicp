; In section 3.2.3 we saw how the environment model described the behavior of procedures with local state. Now we have seen how internal
; definitions work. A typical message-passing procedure contains both of these aspects. Consider the bank account procedure of section 
; 3.1.1:

; (define (make-account balance)
;     (define (withdraw amount)
;         (if (>= balance amount)
;             (begin (set! balance (- balance amount))
;                 balance)
;             "Insufficient funds"))
;     (define (deposit amount)
;         (set! balance (+ balance amount))
;         balance)
;     (define (dispatch m)
;         (cond ((eq? m 'withdraw) withdraw)
;               ((eq? m 'deposit) deposit)
;               (else (error "Unkown request -- MAKE-ACCOUNT" m))))
;     dispatch)

; Show the environment structure generated by the sequence of interactions

; (define acc (make-account 50))
; ((acc 'deposit) 40)
; ((acc 'withdraw) 60)

; Where is local state for acc kept? Suppose we define another account
; (define acc2 (make-account 100))

; How are the local states for the two accounts kept distinct? Which parts of the environment structure are shared between acc and acc2?
; =======
; We'll start with make-account. That's just a procedure defined in the global environment:
 _______________________
| make-account: --------|-----> @-------> parameters: balance
|_______________________|<----- @               body: (define (withdraw amount)...)....

; Now when we define acc, we create an environment that (1) hangs onto the balance, for reference later, and (2) contains definitions
; for withdraw, deposit, and dispatch. acc is defined in the global env as a procedure (whose code is dispatch) whose environment
; is E1.
 _______________________
| make-account: --------|-----> @-------> parameters: balance, pw
|                       |<----- @               body: (define (withdraw amount)...)....
|                       |
| acc: -----------------|-----> @ -------> parameters: m
|_______________________|       @                body: dispatch
                   ^            |
 __________________|____        |
| balance: 50           | E1    |
|                       |<------|
| withdraw: ------------|-----> @ ------> parameters: amount
| deposit: ...          |<----- @               body: (if (>= balance amount)...)
| dispatch: ...         |
|_______________________|

; And now when we evaluate ((acc 'deposit) 40) we build off of E1, creating an env for dispatch and another for deposit, both with
; E1 as the enclosing env.
 _______________________
| make-account: --------|-----> @-------> parameters: balance, pw
|                       |<----- @                body: (define (withdraw amount)...)....
|                       |
| acc: -----------------|-----> @ -------> parameters: m
|_______________________|       @                body: dispatch
                   ^            |
 __________________|____        |
| balance: 50           | E1    |
|                       |<------|
| withdraw: ------------|-----> @ ------> parameters: amount
| deposit: ...          |<----- @               body: (if (>= balance amount)...)
| dispatch: ...         |
|_______________________|
    ^                ^
 ___|_________   ____|_______
| m: 'deposit | | amount: 40 |
|_____________| |____________|
(dispatch         (deposit 40)
    'deposit)    

; The withdraw operation is the same, except our balance is no 90:
 _______________________
| make-account: --------|-----> @-------> parameters: balance, pw
|                       |<----- @               body: (define (withdraw amount)...)....
|                       |
| acc: -----------------|-----> @ -------> parameters: m
|_______________________|       @                body: dispatch
                   ^            |
 __________________|____         |
| balance: 90           | E1    |
|                       |<------|
| withdraw: ------------|-----> @ ------> parameters: amount
| deposit: ...          |<----- @               body: (if (>= balance amount)...)
| dispatch: ...         |
|_______________________|
    ^                ^
 ___|_________   ____|_______
| m: 'withdraw| | amount: 60 |
|_____________| |____________|
(dispatch        (withdraw 60)
    'withdraw)    

; The local storage is kept in E1. If we were to define a second account, acc2, we would create another environment just like
; E1 except that the balance is different. Is any of this shared? The procedures withdraw, deposit, and dispatch, definied in 
; E1 and the env created for acc2 might share code (depending on the interpreter), but the procedure objects would be distinct
; and would have distinct enclosing environments.



