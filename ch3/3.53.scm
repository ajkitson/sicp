; Without running the program, describe the elements of the stream defined by 
; (define s (cons-stream 1 (add-streams s s)))
; ======
; The first element is clearly 1, and we define the following elements as adding the two steams together (doubling?).
; Let's trace through this: 
; - We start with one.
; - (stream-cdr s) will return a pair whose car is the first value produced by (add-streams s s), or 2, and whose cdr is the promise to 
;   get the next value of add-streams, which is adding 2 and 2, right? So I'd expect this stream to double the previous number... to do 
;   powers of 2.
;
; Whoa! I was right:

1 ]=> (define s (cons-stream 1 (add-streams s s)))

;Value: s

1 ]=> (stream-ref s 1)

;Value: 2

1 ]=> (stream-ref s 2)

;Value: 4

1 ]=> (stream-ref s 3)

;Value: 8

1 ]=> (stream-ref s 4)

;Value: 16
