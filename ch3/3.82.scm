; Redo exercise 3.5 on Monte Carlo integration in terms of streams. The stream version of estimate-integral will not have an argument
; telling how many trials to perform. Instead, it will produce a stream of estimates based on successively more trials.
; =======
; The text gives us a stream-based monte-carlo procedure:

(define (monte-carlo experiment-stream passed failed)
    (define (next passed failed)
        (cons-stream
            (/ passed (+ passed failed))
            (monte-carlo 
                (stream-cdr experiment-stream) passed failed)))
    (if (stream-car experiment-stream)
        (next (+ passed 1) failed)
        (next passed (+ failed 1))))

; Now we just need to create the experiment data stream to pass in. Recall that we we take two x values and two y values to 
; delineate an area, and a predicate P to create a shape in that area. We then have a procedure that will test random x and y
; values within the area and determine whether they fall inside or outsied the shape defined by P. With the re-writing of 
; the monte-carlo procedure it will no longer perform the test--the stream will have to have the test results
;
; We'll create a steam of random x and y values (random within their respective ranges), then map our bounds test over them 
; and feed that to monte-carlo to get running pass/fail rates. Then scale the pass-fail rate by the area covered by our x and
; y bounds to get the integral estimate


(define (random-in-range low high)
    (+ (random (- high low)) low))
(define (random-in-range-stream low high)
    (cons-stream (random-in-range low high) (random-in-range-stream low high)))

(define (estimate-integral-stream P x1 x2 y1 y2)
    (let ((x-stream (random-in-range-stream x1 x2))
          (y-stream (random-in-range-stream y1 y2))
          (rect-area (* 1.0 (- x2 x1) (- y2 y1))))
       (let ((in-bounds-stream (stream-map P x-stream y-stream)))
            (scale-stream 
                (monte-carlo in-bounds-stream 0 0)
                rect-area))))


; We can then use the same predicate we did last time to test circle areas:
(define (make-circle-predicate radius cx cy)
    (let ((hypotenuse (square radius)))
        (lambda (x y)
            (<= (+ (square (- x cx))
                  (square (- y cy)))
                hypotenuse))))

; Now we can build our specific circle predicate (1 radius with center at 1,1)
1 ]=> (define circle-1 (make-circle-predicate 1 1 1))
1 ]=> (define c1-stream (estimate-integral-stream circle-1 0 2 0 2))
1 ]=> (stream-ref c1-stream 1000)
;Value: 3.052947052947053
1 ]=> (stream-ref c1-stream 10000)
;Value: 3.020897910208979

1 ]=> (display-n-elems 10 c1-stream)
0
2.
1.3333333333333333
2.
2.4
2.6666666666666665
2.2857142857142856
2.5
2.6666666666666665
2.8


