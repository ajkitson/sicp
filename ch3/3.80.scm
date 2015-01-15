; A series RLC circuit consists of a resistor, a capacitor, and an inductor connected in series, as shown in figure 3.36. If R, L and C 
; are the resisteance, indictance, and capacitance, then the relations between the voltage (v) and the current (i) for the three components
; are described by the equations

; vR = iR(R)
; vL = L(diL/dt)
; iC = C(dvC/dt)

; and the circuit connections dictate the relations

; iR = iL = -iC
; vC = vL + vR 

; Combining these equations show that the state of the circuit (summarized by vC, the voltage across the capacitor, and iL, the 
; current in the inductor) is described by the pair of differential equations

; dvC/dt = -iL/C
; diL/dt = 1/L(vC) - R/L(iL)

; The signal flow diagram representing this system of differntial equations is shown in figure 3.37. 

; Write a procedure RLC that takes as arguments the parapmeters R, L, C of the circuit and the time increment dt. In a manner similar
; to that of the RC procedure of exercise 3.73, RLC should produce a procedure that takes the initial values of the state variables,
; vC0 and iL0, and produces a pair (using cons) of the steams of states vC and iL. using RLC, generate the pair of streams that models
; the behavior of a series RLC circuit wht R = 1 ohm, C = 0.2 farad, L = 1 henry, dt = 0.1 second, and initial values iL0 = 0amps
; and vC0 = 10 volts.
; ======
; The signal-flow diagram in 3.37 is a life-saver here. We can start by filling in the output we need and backfilling from there.
;
; First, RLC needs to return a proceudre, so we'll just have it return a lambda for now that takes vC0 and iL0.

(define (RLC R L C dt)
    (lambda (vC0 iL0)
        ))

; This lambda needs to return two streams as a pair, so we'll pencil that in with a cons.
(define (RLC R L C dt)

    (lambda (vC0 iL0)
        (cons steam1 stream2)))

; The streams are each in integeral, one that gets dVC as the integrand and the other that gets dIL. We'll put those in place,
; and note that we need to define dVC and dIL. We'll might have to delay dVC and diL in passing them to integrel... but we'll just
; note that for now.

(define (RLC R L C dt)

    (lambda (vC0 iL0)
        (cons (integral dVC vC0 dt)
              (integral diL iL0 dt))))

; Now let's define dvC. It gets as input the integral of diL scaled to -1/C. The integral of dIL is what we have as the second
; item in our cons. Since we're using it more than once, we'll define it (note that we can't use a let because iL depends on
; diL, which depends on dVC.... the let nesting gets thrown off). 

(define (RLC R L C dt)
    (lambda (vC0 iL0)
        (define iL (integral diL iL0 dt))
        (define dvC (scale-stream iL (/ -1 C)))
            (cons (integral dVC vC0 dt)
                  iL))))

; Now let's wrap it up by defining diL and moving vC to a definition, and, of course, adding some delays
(define (RLC R L C dt)
    (lambda (vC0 iL0)
        (define vC (integral (delay dVC) vC0 dt))
        (define iL (integral (delay diL) iL0 dt))
        (define dvC (scale-stream iL (/ -1 C)))
        (define diL (add-streams (scale-stream iL (/ (* -1 R) L))
                                 (scale-stream vC (/ 1 L))))
            (cons vC iL)))


; Let's try it out:
1 ]=> (define rlc1 ((RLC 1 1 0.2 0.1) 10 0))

; First the voltage:
1 ]=> (display-n-elems 10 (car rlc1))

10
10
9.5
8.55
7.220000000000001
5.5955
3.77245
1.8519299999999999
-.0651605000000004
-1.8831384500000004

; Now the current:
1 ]=> (display-n-elems 10 (cdr rlc1))

0
1.
1.9
2.66
3.249
3.6461
3.84104
3.834181
3.6359559
3.2658442599999997

; Are these correct?? I found some RLC calculators, but they don't show answers in terms of voltage or current over time and most
; have some extra parameters (e.g. frequency). Example: http://www.wolframalpha.com/input/?i=RLC+circuit+1ohm%2C+1H%2C+0.2uF
;
; Going to set this aside as "point taken" about using delay and streams whose definitions depend on each other and not worry
; about the specific numbers.



