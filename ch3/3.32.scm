; The procedures to run during each time segment of the agenda are kept in a queue. Thus, the procedures for each segment are called in the
; order in which they were added to the agenda (FIFO). Explain why this order must be used. In particular, trace the behavior of an and-gate
; whose inputs change from 0,1 to 1,0 in the same segment and say how the behavior would differ if we stored a segments's procedures in an
; ordinary list, adding and removing procedures only at the front (LIFO).
; ===== 
; Interesting. Let's work through the example and see what jumps out at us.
;
; Before the change, we have an and-gate with two inputs, A and B. A's signal is 0, and B's signal is 1. The gate's output is therefore 0.
; Now, because the value of A and B change in the same segment--they basically swap values--we expect the output of the and-gate to 
; remain 0 (at least upon completion of the propogation).
;
; Let's see what happens when we change the values.
; When A changes from 0 to 1, we compute the new output value of the and-gate to be 1 (A and B are now both 0), and register some code to 
; make this change after the and-delay.
;
; Then B changes from 1 to 0, and we compute the new output value of the and-gate to be 0 (now the B is 0 and A is 1), and register some
; code to make this change after the delay.
;
; So, what happens if we use a LIFO instead of FIFO? Awful things.
; If we use a LIFO approach, we run the code that was scheduled when the signal on wire B changed. This changes the and-gate output to 
; 0. Then we run the code that was scheduled when the wire A's signal changed and we set the output signal to 1... uh oh! This is 
; incorrect since the wire B's signal is 0, so an and-gate should output 0, whatever wire A's signal.
;
; This is why we need to using the FIFO approach. It makes sure that the most recent updates to the output reflect the most recent
; updates to the input. 