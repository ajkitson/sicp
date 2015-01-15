; Exercise 3.6 discussed generalizing the random-number generator to allow one to reset the random-number sequence so as to produce 
; repeatable sequences of "random" numbers. Produce a stream forumlation of this same generator that operates on an input stream of 
; requests to generate a new random number or to reset the sequence to a specified value and that produces the desired stream of
; random numbers. Don't use assignment in your solution.
; ========
; We're operating on a request stream and need to produce the matching stream of "random" numbers. How does this work? Well, we
; can alway just have the random number build on the themselves, calling random-update on whatever has been built up in the stream
; so far, and then inserting random-init when we get a reset

; We'll need to define random-init and random-update... something easy to read for testing:
(define random-init 0)
(define (random-update n) (+ n 1))

; Then we just merge the request and random number streams using map, using random update if the request stream asks us to generate
; and random-init if it asks us to reset. Also, we need a way to reference our random-number stream. We can't use random-numbers
; since it's a procedure that returns a stream and not the stream itself. So we'll just create a random-with-requests that is the
; stream of random numbers that has access to the request stream, too.

(define (random-numbers request-stream)
    (define (process-req n req)
        (cond ((eq? req 'generate) (random-update n))
              ((eq? req 'reset) random-init)
              (else (error "Unrecognized command -- RANDOM-NUMBERS" (list n req)))))
    (define random-with-requests
            (cons-stream random-init
                (stream-map process-req random-with-requests request-stream)))
    random-with-requests)


; If we create a stream of generate requests, we get our "random" counting, as expected:
1 ]=> (define generate-stream (cons-stream 'generate generate-stream))
1 ]=> (define rnums (random-numbers generate-stream))
1 ]=> (display-n-elems 10 rnums)
0
1
2
3
4
5
6
7
8
9

; Now let's create a stream with a reset and see how that works. We'll have the request stream reset every 6 numbers.
1 ]=> (define req-str (stream-map (lambda (n) (if (= (remainder n 6) 0) 'reset 'generate)) integers))

; And it works!
1 ]=> (display-n-elems 30 (random-numbers req-str))

0
1
2
3
4
5
0
1
2
3
4
5
0
1
2
3
4
5
0
1
2
3
4
5
0
1
2
3
4
5


