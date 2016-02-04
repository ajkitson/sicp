; Given a one argument procedure p and an object a, p is said to halt on a if
; evaluating the expression (p a) returns a value (as opposed to terminating with
; an error message or running forever). Show that it is impossible to write a
; procedure halts? that correctly determines whether p halts on a for any
; procedure p and object a. Use the following reasoning: If you had such a
; procedure halts?, you could implement the following program:
;
; (define (run-forever) (run-forever))
;
; (define (try? p)
;   (if (halts? p p)
;     (run-forever)
;     'halted))
;
; Now consider evaluating the expression (try try) and show that any possible
; outcome (either halting or running forever) violates the intended behavior
; of halts?
; =================
; Suppose (halts? try try) evaluates to true. Then we fall into the consequent
; clause and call run-forever. In this case (try try) does not, in fact, halt.
; This means that halts? was incorrect.
;
; OK, now suppose (halts? try try) evaluates to false. Then we fall to the
; alternative clause and return 'halted. That is, (try try) did, indeed, halt,
; even though halts? said it would not.
;
; In both cases we have a contradiction, meaning that halts? cannot work for
; any procedure p and object a. 