; Figure 3.27 shows a ripple-carry adder formed by stringing together n full-adders. This is the simlest form of parallel adder for adding
; two n-bit binary numbers. The inputs A1, A2, A3, ... An and B1, B2, B2, ... Bn are the two binary numbers to be added (each Ak and Bk is
; a 0 or a 1). The circuit generates S1, S2, S3,... Sn, the n bits of the sum, and C, the carry from the addition. Write a procedure
; ripple-carry-adder that generates this circuit. The procedure should take as arguments three lists of n wires each--the Ak, Bk, and the
; Sk--and also another wire C. The major drawback of the ripple-carry-adder is the need to wiat for the carry signals to propogate. What is
; the delay needed to optain the cmoplete output from an n-bit ripple-carry adder, expressed in terms of the dalays for and-gates, or-gates,
; and inverters?
; =====
; Well, each ripple-carry-adder has n full-adders. Each full-adder has an or-gate plus two half-adders. So that's an or-gate and, inside
; each half-adder, an or-gate, two and-gates, and an inverter. Now, not all wires go through each of these gates, but if we're assuming
; that the delays are synchronous and we hit each gate (changes to wire B and C do, not A), we get:
;           n * (3 or-gates, 4 and gates, and 2 inverters).
;
; ======
; UPDATE: 
; Now that we know a bit more about how these delays are implemented (see 3.29), we can add this up a bit better. The result is still
; n * (full-adders), but we can better understand what's happening in the full-adders
;
; The full adder is composed of two half-adders an an or-gate. The or-gate receives the output of the two half-adders. One of the
; half-adders receives the output of the other half-adder. Each half-adder is directly hooked up to an input to the full-adder.
;
; We'll look at the or-gate first. How many or-gate delays are there? Well, we get a new or-gate delay each time the output of either
; half-adder changes. Supposing we change both inputs to the full adder, the output of both half-adders could change, giving us a running
; total of two or-delays. But then we have to add another because one half-adder feeds into the other, so if it's output changes, the 
; other half-adder's output could change again, making three or-gate delays.
; 
; This gives us 0 - 3 or-gate delays for each full adder, two of which can happen in the same timeslot.
;
; Now let's look at the half-adders. The half-adder has two inputs, each hooked directly to an and-gate and an or-gate. 
; This gives us an and-gate and or-gate delay for each changed input. The and-gate feeds to an inverter and to an output (C). This
; gives us one inverter delay IF the signal changes after the and-gate. The inverter, which always changes value on the output,
; feeds into an and-gate, whose other input is the initial or-gate. This gives us an and-gate delay if the value of the initial or-gate
; changes and another if the value of the initial and-gate changes. 
;
; This totals up to an and-delay and or-delay for each changed input. After that, it's a matter of how the computations work out. If 
; the or-gate value changes, we add a final and-delay. If the initial and-gate value changes, we add an inverter delay and an and-delay.
; Depending on how the inverter delay and or-delay are sequenced, this could result in the final and-gate processing once or twice. If
; the inverter changes the signal to and before the or-gate does, then the inputs to the final and-gate won't change. But if the or-gate
; triggers an and-delay and the inverter registeres an and-delay for later, then the and-gate will potentiall produce two different values.
;
; So it's an and-delay and or-delay for each changed input, possibly an inverter delay, and if an inverter delay, at least one and-delay, 
; maybe two if the or-gate output changed.
; 
; 1-2 and-delays, 1-2 or delays, 1 possible inverter delay, another two possible and-delays (in possibly different timeslots).
;
; So, overall we have 
; n * (0-3 or delays + 2 * (1-4 and-delays, 1-2 or-delays, 0-1 inverter delays))

