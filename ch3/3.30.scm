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
; that the delays are synchronous and we hit each gate, we get n * 3 or-gates, 4 and gates, and 2 inverters.