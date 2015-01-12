; Alyssa P. Hacker is desining a system to process signals coming from physical sensors. One important feature she wishes to produce is a 
; signal that describes the zero crossing of the input signal. That is, the reulting signal should be +1 whenever the input signal changes
; from negative to positive, -1 whenever the input signal changes from positive to negative, and 0 otherwise. (Assume that the sign of
; a 0 input is positive.) For example, a typical input signal with its associate zero-crossing signal would be:

; ... 1  2  1.5  1  0.5  -0.1  -2  -3  -2  -0.5  0.2  3  4 ....
; ...  0  0   0   0   0    -1   0   0   0     0    1   0  0 ....

; In Alyssa's system, the signa from the senors is represented as a stream  sense-data and the stream zero-crossings is the corresponding
; stream of zero crossings. Alyssa first writes a procedure sign-change-detector that takes two values as arguments and compare the 
; signs of the values to produce an appropriate 0, 1, or -1. She then constructs her zero-crossing stream as follows:

; (define (make-zero-crossings input-stream last-value)
;     (cons-stream
;         (sign-change-detector (stream-car input-stream) last-value)
;         (make-zero-crossings (stream-cdr input-stream)
;                              (stream-car input-stream))))
; (define zero-crossings (make-zero-crossings sense-data 0))

; Alyssa's boss, Eva Lu Ator, walks by and suggest that this program is approximately equivalent to the following one, which uses the 
; generalized version of steam-map from exercise 3.50:

; (define zero-crossings
;     (stream-map sign-change-detector sense-data ??))

; Complete the program by supplying the indicated expression (??).                            
; =======
; Eva is suggesting using the capability where stream-map takes multiple streams and combines their cars with the supplied 
; procedure. We need to pass the two adjacent values from sense-data to sign-change-detector. We can use the technique we employed 
; in 3.72 in the adjacent procedure, but in reverse. Instead of passing a stream and it's cdr, we will pass a sense-data and 
; use cons-stream to add a 0 to the front of sense-data and pass that as the second param. That gets us our adjacent pairs, but with 
; the offset in the opposite direction of what we had in 3.72.

(define zero-crossings
    (stream-map sign-change-detector sense-data (cons-stream 0 sense-data)))

; Before we can try this out we need to implement sign-change-detector:
(define (sign-change-detector cur prev)
    (if (< prev 0)
        (if (< cur 0) 0 1)
        (if (< cur 0) -1 0)))

; Then we need a sense-data stream. We'll just make something up that crosses 0 a few times.


1 ]=> (define sense-data (stream-map sin integers))
1 ]=> (display-n-elems 10 sense-data)
.8414709848078965
.9092974268256817
.1411200080598672
-.7568024953079282  <<<< Should be -1
-.9589242746631385
-.27941549819892586
.6569865987187891  <<<<< Should be +1
.9893582466233818
.4121184852417566
-.5440211108893699  <<<<<< Should be -1


1 ]=> (define zero-crossings
    (stream-map sign-change-detector sense-data (cons-stream 0 sense-data)))
1 ]=> (display-n-elems 10 zero-crossings)
0
0
0
-1
0
0
1
0
0
-1


