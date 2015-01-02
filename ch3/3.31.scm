; The internal procedure accept-action-procedure! defined in make-wire specifies that when a new action procedure is added to a wire, the 
; procedure is immediately run. Explain why this initialization is necesary. n particular, trace through the half-adder example in the 
; paragraphs above and say how the system's response would differ if we had defined accept-action-procedure! as 
; (define (accept-action-procedure! proc)
;     (set! action-procedures (cons proc action-procedures)))
; =======
; We need to run the new action right away in order to put the circuit in an internally consistent initial state. A simple example is an 
; inverter. Suppose we connect wire A with wire B using the inverter and A and B have an initial signal of 0. By running the actions as 
; soon as we add them, we convert wire B's signal to 1 (or rather, we schedule this to happen first thing). Suppose we did not do this. 
; In that case, wire A and wire B would both be 0 initially. When we changed the value to wire A to 1, the inverter would compute wire
; B's new value correctly (it will be 0), but when it updates wire B, set-signal! will not actually change the value of wire B, since 
; it already had the value of 0 initially. This means that wire B will not run through whatever procedures wire B was supposed to run 
; through when its signal changed. Uh oh!
;
; The half-adder is a more complex case of this. If we didn't run the procedures when added, the wires would not have the correct
; iniital states, which would throw off the downstream updates. The particular problem with the half-adder involves the wire
; coming out of the inverter and feeding into the last and-gate. This inverter is fed by the first and-gate, and it will not regognize
; changes to this and-gate's output or pass them along to the final and-gate (at least not until after the first run, once its state
; is set up correctly). 
;
; The other gates wouldn't really be affected since if all inputs are initially zero, the and-gate and or-gate outputs are zero to and
; therefore wouldn't have any changes to propagate. The final and-gate's output would also be zero since, though the wire coming from the
; inverter is 1, the wire from the or-gate is 0. 
