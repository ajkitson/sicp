; Generalize the solve-2nd procedure of exercise 3.78 so that it can be used to solve the general second-order differential equations
;  d^2y/dt^2 = f(dy/dt, y)
; ========
; What details are we abstracting away? The part involving a and b. Intead of scaling dy and y by a and b then adding the results, we'll
; take a function f that we'll map over dy and y. This is basically removing the scale and add boxes in figure 3.35 and replacing them
; with a box that just runs f over the inputs y and dy to produce the stream ddy. We don't need to know what f does as long as it 
; produces a stream that can be fed into integral to create dy.
;
; Simple change to make, but still not sure how to test it :(

(define (solve-2nd f y0 dy0 dt)
    (define y (integral (delay dy) y0 dt))
    (define dy (integral (delay ddy) dy0 dt))
    (define ddy (stream-map f dy y))
    y)