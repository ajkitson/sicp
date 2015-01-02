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
; =====
; UPDATE: Read through the implementation of the delay, and here's how it works:
; - The update procedures are registered when the wires are attached to the different gates, and they are run when attached. But that's
;   not the primary case.
; - Once you build out a circuit, you change the value of one or more of the wires. When you do this, we it calls each of the procedures
;   that had been registered to be run whenever the signal changed. However (at least for our gates), these procedures which run 
;   immediately, only schedule some more code to be run later, after a delay. It's this process that's of interest.
; - When code is scheduled to be run after a delay, it's added to an agenda, with different pieces of code to be run at different times.
;   Any given time may have multiple pieces of code to be run; they are run in the order in which they were added (FIFO). 
; - The agenda is built when the value on the wire is changed, but we do not run through the agenda until the propogate procedure is 
;   executed.
; - If two inputs to a gate change, that gate will be evaluated twice and produce two corresponding outputs, but since the values for the 
;   input wires will not have changed, the output should be the same. Since set-signal! only runs through the registered tasks when the
;   signal actually changes, we will only do this for the first set-signal call (assuming the value actually changed).
; - The propogation stops only when the agenda is empty
; - Code on the agenda can add more code to the agenda, and so perpetuate the propogation.
;
; Now we can add up our delays. 
; - One inverter delay for each changed input 
; - One and-gate delay for each inverted input (since value always changes with inversion, an and-gate delay for each changed input)
; - One inverter delay IF the output of the and-gate changed.
;
; Note that the first inverter delays are added in the same timeslot, the and-gate delays are also in the same timeslot (because it's
; the same and-gate delay added from the same timeslot (the one shared by the two inverter delays)), and the last inverter delay
; has it's own timeslot, after the and-gate delay. 
;
; It looks like we get into parallelization more soon and will better understand what sharing a timeslot actually means in practice.








