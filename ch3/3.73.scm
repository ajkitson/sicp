; We can model electrical circuits using streams to represent the values of currents or voltages at a sequence of times. For instance,
; suppose we have an RC cicuit consisting of a resistor of resistance R and a capacitor of capacitance C in series. The voltage response
; v of the circuit to an injected current i is determined by the formula in figure 3.33, whose structure is shown by the accompanying 
; signal-flow diagram.

; Write a procedure RC that models this circuit. RC should take as inputs the values of R, C, and dt and should return a procedure that 
; takes as inputs a stream representing the current i and an initial value for capacitor voltage v0 and produces as output the stream of 
; voltages v. For example, you should be able to use RC to model an RC circuit with R = 5 ohms, C = 1 farad, and a 0.5 second time step
; by evaluating (define RC1 (RC 5 1 0.5)). This defines RC1 as a procedure that takes a stream representing the time sequence of currents
; and an initial capacitor voltage and produces the output stream of voltages.
; =====
; Here's the formula we're modeling: v = v0 + 1/C (integral from 0->t of idt) + Ri.
; The signal-flow diagram makes it a bit clearer:
;
; i ---.-> scale: 1/C ---> integral: idt (v0 as initial) ---,
;      |                                                    |
;      '-> scale: R ----------------------------------------'----> add both branches
;
;
; We have an integral stream procedure from earlier in the text:
(define (integral integrand initial-value dt)
    (define int
        (cons-stream initial-value
                     (add-streams (scale-stream integrand dt)
                                  int)))
    int)
;
; We then just need to scale C and feed it to our integral. Then scale R and combine it, with the scaled-C in our add-streams

(define (RC r c dt)
    (lambda (i v0)
        (let ((scaled-R (scale-stream i r))
              (scaled-C (scale-stream i (/ 1 C))))
            (add-streams scaled-R
                        (integral scaled-C v0 dt)))))

; And this works. Here we've got a simple (and I have no idea how realistic) case where there's an initial value of 0 and we
; input is a constant stream of ones. We would espect the result to simply be R + idt, or 5 + 0.5*(number of intervals). As 
; expected, we start at 5 and move up 0.5 with each interval

1 ]=> (display-n-elems 10 (RC1 ones 0))

5
5.5
6.
6.5
7.
7.5
8.
8.5
9.
9.5

