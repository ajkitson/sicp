; How many additions are performed when we compute the nth Fibonacci number using the definition of fibs based on add-streams procedure?
; Show that the number of additions would be exponentially greater if we had implemented (delay <exp>) simply as (lambda () <exp>), 
; without using the optimization provided by the memo-proc procedure described in section 3.5.1.
; =======
; Let's start with the fib procedure based on add-streams:

(define fibs
    (cons-stream 0
        (cons-stream 1
            (add-streams (stream-cdr fibs) fibs))))

; We do n - 2 additions when we compute the nth fibonacci. It scales with n because to get the next fibonacci we just add the previous
; two (which we have tucked away thanks to memoization). And it's n - 2 because the first two are given--we don't have to call add-streams
; for them.
;
; If we didn't have the memoization, we would have many more additions. This is because we would have to build out the fib stream
; each time we calculated a fiboonacci number. And we do this not just for the number we ask for (e.g. the 5th fibonacci). Because
; the fibonacci is defined in terms of itself, for each fib we calculate (except the first two), we must calculate the two lower
; fibs below it, which must calculate the ones below them, etc. 
; 
; So generate the 5th fibonacci, we need to:
;   - add the 4th and 3rd fibs
;       - add the 3rd and 2nd fibs
;           - add the 1st and 2nd fibs (0 and 1)
;       - add the 2nd and 1st fibs (0 and 1)
;
; And to compute the sixth fib we need to:
; - add the 5th and 4th fibs
;   - add the 4th and 3rd fibs (computing the 5th)
;       - add the 3rd and 2nd fibs
;           - add the 1st and 2nd fibs (0 and 1)
;       - add the 2nd and 1st fibs (0 and 1)
;   - add the 3rd and 2nd fibs (computing the 4th)
;       - add the 1st and 2nd fibs (0 and 1)
;   - add the 2nd and 1st fibs (0 and 1)

; This, as you can see, branches in a way that grows exponentially.