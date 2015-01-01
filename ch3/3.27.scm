; Memoization (also called tabulation) is a technique that enables a procedure to record, in a local table, values that have previously been
; computed. This technique can make a vast difference in the performance of a program. A memoized procedure maintains a table in which values
; of previous calls are stored using as keys the arguments that produced those values. When the memoized procedure is asked to compute a
; value, it first checks the table to see if the value is already there and, if so, just returns that value. Otherwise, it computes the new
; value in hte ordinary way and stores this in the table. As an example of memoization, recall from section 1.2.2 the exponential process
; for computing fibonacci numbers:

; (define (fib n)
;     (cond ((= n 0) 0)
;           ((= n 1) 1)
;           (else (+ (fib (- n 1))
;                    (fib (- n 2))))))

; The memoized version is:

; (define memo-fib 
;     (memoize (lambda (n)
;         (cond ((= n 0) 0)
;               ((= n 1) 1)
;               (else (+ (memo-fib (- n 1))
;                        (memo-fib (- n 2))))))))

; where memoize is defined as:

; (define (memoize f)
;     (let ((table (make-table)))
;         (lambda (x)
;             (let ((previously-computed-result (lookup x table)))
;                 (or previously-computed-result
;                     (let ((result (f x)))
;                         (insert! x result table)
;                         result))))))

; Draw an environment diagram to analyze the computation of (memo-fib 3). Explain why memo-fib computes the nth Fibonacci in a number of
; steps proportional to n. Would the scheme still work if we had simply defined memo-fib to be (memoize fib)?
; =======
; memo-fib take a number of steps propoprtional to n because only one of the recursive memo-fib calls needs to actually compute it's 
; value--the other can just look it up in the table. Once one of the branches bottom out, the other calls just look at the numbers it
; calculated along the way, so they don't need to do any branching of their own.
;
; This wouldn't work if memo-fib were defined as (memoize fib) becase then recursive call within fib would not be to the memoized
; version. So we would memoize the final result, but not the intermediate fibs we need to calculate to get the final result, and that's
; where the real savings; it's in memoizing the intermediate calls that we prevent the branching calculations the lead to exponential 
; steps.
;
; Here's the diagram, first, defining memo-fib creates an environment that has the table in its local state (whether this table itself
; points to a dispatch procedure with its own local state or a pointer structure depends on the implementation of table... we won't
; get into it here):

global
 ______________
| memo-fib: ---|----> @ -----> parameters: x
|______________|      @              body: (lambda (x) ....)
       ^
    ___|__________________________________________
E1 | table: <results table, however implemented>  |
   |______________________________________________|

; Now, when we evaluate (memo-fib 3), we create a series of environmens off E1, one for each call to memo-fib. Each memo-fib call
; creates an environment for the lambda wrapper memoize returns, an environment for the previously-computed-result value established 
; in the let block, and if there is not previous value, an environment for result and finally an environment for the lambda-ized 
; version of fib (with the global env as its parent). 
;
; We don't see much savings with (memo-fib 3) since 1 is the only repeated n (far end of diagram). But if we were to do (fib 4), we
; start to see it really kick in
;
; (Note: we assume right to left eval below, and omitting table operation -- e.g. insert after getting a value)

    global
     ______________
,-->| memo-fib: ---|----> @ -----> parameters: x
|   |______________|      @              body: (lambda (x) ....)
|           ^              |
|        ___|______________|____________________________________________________________________________________________________________________________________________________________
|    E1 | table: <results table, however implemented>                                                                                                                                   |
|       |_______________________________________________________________________________________________________________________________________________________________________________|  
|            ^                                   ^                                   ^                                   ^                                    ^
|        ____|___                            ____|___                            ____|___                            ____|___                              ___|____                         
|    E2 | x: 3   | (memo-fib 3)          E6 | x: 1   | (memo-fib 1)          E10| x: 2   | (memo-fib 2)          E14| x: 0   | (memo-fib 0)            E18| x: 1   | (memo-fib 1)                     
|       |________|                          |________|                          |________|                          |________|                            |________|
|            ^                                   ^                                   ^                                   ^                                     ^
|        ____|_______                        ____|_______                        ____|_______                        ____|_______                          ____|_______                                                 
|    E3 | prc: false | (let ((prc        E7 | prc: false | (let ((prc        E11| prc: false | (let ((prc        E15| prc: false | (let ((prc          E15| prc: 1     | (let ((prc 
|       |____________|         ...)))       |____________|         ...)))       |____________|         ...)))       |____________|         ...)))         |____________|         ...)))
|            ^                                   ^                                   ^                                   ^
|        ____|________                       ____|________                       ____|________                       ____|________
|    E4 | result: TBD | (let ((result    E8 | result: TBD | (let ((result    E12| result: TBD | (let ((result    E16| result: TBD | (let ((result 
|       |_____________|          ...)))     |_____________|          ...)))     |_____________|          ...)))     |_____________|          ...)))
|___________,____________________________________,____________________________________,____________________________________,
        ____|__                              ____|__                              ____|__                              ____|__
    E5 | n: 3  | (lambda (n) ...)        E9 | n: 1  | (lambda (n) ...)        E13| n: 2  | (lambda (n) ...)        E17| n: 0  | (lambda (n) ...)
       |_______| finally start              |_______|                            |_______|                            |_______| 
                 computing fib 3
                 parent env is global





