; Eva Lu Ator has a criticism of Louis' approach in exercise 3.75. The program he wrote is not modular, because it intermixes the 
; operation of smoothing with the zero-crossing extraction. For example, the extractor should not have to be changed if Alyssa finds
; a better way to condition her input signal. Help Louis by writing a procedure smooth that takes a stream as input and produces
; a stream in which each element is the average of two successive input stream elements.  Then use smooth as a component to implement
; the zero-crossing detector in a more modular style.
; ======
; Here's what we'll do:
; - create an adjacent-pairs stream
; - map an averageing procedure over that
; - wrap this in smooth
; - use the stream-map version of zero-crossing
; - feed this to the zero-crossing procedure

(define (adjacent-pairs s) ;; 
    (stream-map list s (stream-cdr s)))

(define (smooth s)
    (stream-map (lambda (p) (/ (+ (car p) (cadr p)) 2))
                (adjacent-pairs s)))

(define (zero-crossings s)
    (stream-map sign-change-detector s (cons-stream 0 s)))

; Now, for any sense-data stream that she wants to get the zero crossings on, Alyssa can just define it as 
; (zero-crossing (smooth <input-stream>))
;
; Note that the smooth procedure throws the stream a step off. The first value in the smoothed stream is the average of the 
; values 1 and 2 on the input, and so forth. If this is an issue, you can always feed it a stream with a dummy value on the front.
; That seems better than trying to do something overly clever in adjacent pairs or smooth.
;
; Let's try it out. We'll use sine again:


1 ]=> (define sense-data (stream-map sin integers))
1 ]=> (display-n-elems 10 sense-data)

.8414709848078965
.9092974268256817
.1411200080598672
-.7568024953079282
-.9589242746631385
-.27941549819892586
.6569865987187891
.9893582466233818
.4121184852417566
-.5440211108893699


; And here's what adjacent pairs look like:
1 ]=> (display-n-elems 10 (adjacent-pairs sense-data))

(.8414709848078965 .9092974268256817)
(.9092974268256817 .1411200080598672)
(.1411200080598672 -.7568024953079282)
(-.7568024953079282 -.9589242746631385)
(-.9589242746631385 -.27941549819892586)
(-.27941549819892586 .6569865987187891)
(.6569865987187891 .9893582466233818)
(.9893582466233818 .4121184852417566)
(.4121184852417566 -.5440211108893699)
(-.5440211108893699 -.9999902065507035)

; And here's the smoothed sense data:
1 ]=> (display-n-elems 10 (smooth sense-data))

.8753842058167891
.5252087174427744
-.3078412436240305
-.8578633849855333
-.6191698864310322
.1887855502599316
.8231724226710855
.7007383659325692
-.06595131282380665
-.7720056587200367

; And the zero-crossings using smoothed input:
1 ]=> (display-n-elems 10 (zero-crossings (smooth sense-data)))

0
0
-1
0
0
1
0
0
-1
0




