; Suppose that we implement test-and-set! using an ordinary procedure as shown in the text, without attempting to make the operation atomic.
; Draw a timing diagram like the one in figure 3.29 to demonstrate how the mutex implementation can fail by allowing two processes to 
; acquire the mutex at the same time.
; ========
; Let's take a look at test-and-set! first:
;
; (define (test-and-set! cell)
;     (if (car cell)
;         true
;         (begin 
;             (set-car! cell true)
;             false)))
;
; The gap we need to be concerned about here is the one that exists between when we check (if (car cell)...) and when we evaluate
; (set-car! cell true). If we have one processe following close on the heels of another, the first might check (car cell), see that
; it's true, and so get ready to set the car to true. But there's a gap and in this gap the second process might check (car cell), too, 
; see that it's not set yet, and therefor assume it has the mutex and can proceed. The first process then sets the car cell, followed
; shortly by the second. And each process thinks it currently has exclusive access to the whatever resources the mutex is protecting.

P1                                    P2
evaluates (car cell): true           
                                evaluates (car cell): true           
sets the car of cell to false
                                sets the car of cell to false
proceeeds, assuming it has
exclusive access to the 
protected resources
                                proceeeds, assuming it has
                                exclusive access to the 
                                protected resources
