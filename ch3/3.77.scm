; The integral procedure used above was analogous to the "implicit" definition of the infinite stream of integers in section 3.5.2. 
; Alternatively, we can give a definition of integeral that is more like integers-starting-from (also in section 3.5.2):

; (define (integeral integrand initial-value dt)
;     (cons-stream initial-value
;                  (if (stream-null? integrand)
;                     the-empty-stream
;                     (integeral (stream-cdr integrand)
;                                (+ (* dt (stream-car integrand))
;                                   initial-value)
;                                dt))))

; When used in a system with loops, this procedure has the same problem as does our original version of integral. Modify the procedure 
; so that it expects the integrand as a delayed argument and hence can be used in the solve procedure shown above.
; ========
; We'll start by playing around with the version of integral in the text, just to get a feel. Here's the code (without modifications
; to be used in systems with loops):

(define (integral integrand initial-value dt)
    (define int 
        (cons-stream initial-value
                     (add-streams (scale-stream integrand dt)
                                  int)))
    int)

; We'll feed it the set of integers as the integrands, scaled to dt (basically x = y). 
; We expect the integral at point n to be 1/2 * n^2:

1 ]=> (define up (integral (scale-stream integers 0.1) 0 0.1))
1 ]=> (stream-ref up 99)
;Value: 49.5

; This is about right. Keep in mind that although we're looking at index 99, it's the 100th values, which, with dt = 0.1,
; corresponds to x = 10. So 10^2 / 2 ~= 49.5
;
; And if we slice it a bit finer with a smaller dt, we get better results:
1 ]=> (define up (integral (scale-stream integers 0.01) 0 0.01))
1 ]=> (stream-ref up 999)
;Value: 49.949999999999996

1 ]=> (define up (integral (scale-stream integers 0.001) 0 0.001))
1 ]=> (stream-ref up 9999)
;Value: 49.99500000000002

; OK, so that's great as far as it goes. Where it breaks down is when we try to use it in a systems that involve loops. The one we talk
; about in the text is solving differential equations. For example dy/dt = f(y), where a function on y is defined in terms of its 
; derivative. 

; This is the procedure that would solve for y (with a stream!):
(define (solve f y0 dt)
    (define y (integral dy y0 dt))
    (define dy (stream-map f y))
    y)

; But it doesn't work because the definitions of y and dy depend on each other, and the form doesn't accmodate the partial answer we 
; need in order to bootstrap the y and dy streams. Just trying to define solve creates an error:
Premature reference to reserved name: dy

; But we can use delay to prevent dy from being evaluated when we define y and then update integral to use force to evaluate dy when 
; it needs it, but not before. This works because we know that, by the time we actually need dy in integral, it will be defined and 
; have some values built out.

(define (solve f y0 dt)
    (define y (integral (delay dy) y0 dt))
    (define dy (stream-map f y))
    y)

(define (integral integrand initial-value dt)
    (define int 
        (cons-stream initial-value
                     (add-streams (scale-stream (force integrand) dt)
                                  int)))
    int)

; Now we can use it, for example, to find e:
1 ]=> (stream-ref (solve (lambda (y) y) 1 0.001) 1000)
;Value: 2.716923932235896


; So now for the actual question: we're going to do the same delay/force modification to this version of the integral stream:
(define (integral integrand initial-value dt)
    (cons-stream initial-value
                 (if (stream-null? integrand)
                     the-empty-stream
                     (integral (stream-cdr integrand)
                               (+ (* dt (stream-car integrand))
                                  initial-value)
                               dt))))

; Which works as expected on non-loop systems
1 ]=> (define up (integral (scale-stream integers 0.01) 0 0.01))
1 ]=> (stream-ref up 999)
;Value: 49.949999999999996

; But doesn't work for solve:
1 ]=> (stream-ref (solve (lambda (y) y) 1 0.001) 1000)
;Aborting!: maximum recursion depth exceeded

; The main difference here is that we want to force integrand once, instead of with each instance it's used, and if we 
; make delayed-integrand delayed, then the recursive call needs to delay it, too
(define (integral delayed-integrand initial-value dt)
    (cons-stream initial-value
                 (let ((integrand (force delayed-integrand)))
                     (if (stream-null? integrand)
                         the-empty-stream
                         (integral (delay (stream-cdr integrand))
                                   (+ (* dt (stream-car integrand))
                                      initial-value)
                                   dt)))))   


; And here we're using it to compute e again:
1 ]=> (stream-ref (solve (lambda (y) y) 1 0.001) 1000)
;Value: 2.716923932235896

