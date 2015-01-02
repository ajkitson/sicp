; Another way to construct an or-gate is as a compound digital logic device, build from and-gates and inverters. Define a procedure or-gate
; that accomplishes this. What is the delay time of the or-gate in terms of and-gate-delay and inverter-delay?
; =====
; Ah! This takes me back to my introductory logic class. Set aside the coding and let's talk about how to represent the concept OR using
; only AND and NOT. 
;
; The truth table for OR is:
; a    b   a or b
; T    T    T
; T    F    T 
; F    T    T 
; F    F    F
;
; The thing to notice is that, if we flip the values of a and b, this is essentially the converse of the AND truth table:
; a    b   a and b
; F    F    F
; F    T    F 
; T    F    F 
; T    T    T
; If we flip all the values of the above, we get the or truth table.
;
; So if we flip the values of a and b, compute their AND, then flip that value, we have or.
; OR = NOT (NOT a AND NOT b)
;
; Hence, we can build the or-gate as a compound device using AND and NOT like this:

(define (or-gate input-1 input-2 output)
    (let ((in-1-inverse (make-wire))
          (in-2-inverse (make-wire))
          (inverse-answer (make-wire)))
        (inverter input-1 in-1-inverse)
        (inverter input-2 in-2-inverse)
        (and-gate in-1-inverse in-2-inverse inverse-answer)
        (inverter inverse-answer output)
        'ok))

; How we do the delay math isn't entirely clear to me yet. We clearly have three inverters and one and-gate. But can the inputs 
; change simultaneously? If so, what runs in parallel or has overlapping delays? If not, what order do they run in. For example,
; if input-1 changes, then we have an inverter delay, an and-gate delay and a final inverter delay. But can input-1 and input-2 
; change simultaneously (or whatever the equivalent to simultenaity would be in this system)? If so, then do we compute the and-get
; twice, once for each changed value, or can we compute it once for both of the changes? And suppose input-2 changes while we're still
; in the middle of computing the response for an input-2 change (that is, we haven't yet changed the output wire signal). 
;
; In any case, let's just say that it's two inverter delays and an and-gate delay for a change in a single input wire, and beyond that
; we need to know more about the system to say how simutaneous or overlapping changes are handled.