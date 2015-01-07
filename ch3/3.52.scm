; Consider the sequence of expressions:

; (define sum 0)
; (define (accum x)
;     (set! sum (+ x sum))
;     sum)

(define seq (stream-map accum (stream-enumerate-interval 1 20)))
(define y (stream-filter even? seq))
(define z (stream-filter (lambda (x) (= (remainder x 5) 0)) seq))

(stream-ref y 7)
(display-stream z)

; What is the value of sum after each of the above expressions is evaluated? What is the printed response to evaluating the stream-ref and
; display-stream expressions? Would these responses difere if we had implemented (delay <exp>) simply as (lambda () <exp>) without using 
; the optimization provided by memo-proc? Explain.
; =======
; I liked the footnote on this--reminder that these problems are helpful for understanding how steams work but that actually programming
; in this style is "odious".
; 
; The way to think about this is how far down seq we need to traverse in order to evaluate each expression. Each step we take down
; seq will set sum to be the value at that index of seq.
;
; Sum starts off as 0
; When we define seq, we evaluate the first value (and therefore run accum once), which is 1, so sum = 1
; When we define y, we get the first even val from seq: 1, 3, 6 -- so sum is 6 at this point.
; Then we define z, we get the first val from seq that is a multiple of 5: 1, 3, 6, 10, so at this point sum = 10
;
; (stream-ref 7) pushes us to the 8th even number index 7: 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, so sum = 136
; (display-stream z) pushes us to the end (since we need to check each value to see if it's a multiple of 5 ):
;       1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153, 171, 190, 210
;  At the end sum = 210
;

1 ]=> sum
;Value: 0

1 ]=> (define seq (stream-map accum (stream-enumerate-interval 1 20)))
1 ]=> sum
;Value: 1

1 ]=> (define y (stream-filter even? seq))
1 ]=> sum
;Value: 6

1 ]=> (define z (stream-filter (lambda (x) (= (remainder x 5) 0)) seq))
1 ]=> sum
;Value: 10

1 ]=> (stream-ref y 7)
;Value: 136

1 ]=> (display-stream z)
10
15
45
55
105
120
190
210
;Value: done
1 ]=> sum
;Value: 210

; These values would be different if we weren't using the memoized version of delay. By using the memoized version, accum is only run
; once per value in the stream. This means that sum is always equal to the value of the furthest element we've looked at (highest index).
; But if we didn't use the memoized version, we would run accum *each time* we traversed over an index. 
; 
; We'll use a simple example. Suppose we define seq as above. Sum is now = 1, which is also the value at index zero. We'll consider 
; evaluating (stream-ref seq 2) twice.
; 
; With a memoized version of delay, sum is set as described above. We get index 0 (1) since it's already the calcuclate car of the stream.
; Then we run accum to get index 1 (3), and run accum again to get index 2 (6). Each time we run accum we update sum, so sum is now 
; equal to 6. If we evaluate (stream-ref seq 2) again, sum does not change. This is because we do not actuallt run accum again. We instead
; just return the previously computed, memoized values.
; 
; If we do not use a memoized version of delay, however, the second evaluation of (steam-ref seq 2) changes. Because delay isn't memoized,
; we evaluated accum again for each index we go over. This means we take sum, which is already 6, and increment it by 3 when we get
; index 1 and by 6 when we get index 2, making the sum 15. Moreover, because sum is returned as the value for accum, our new stream values
; are off, too: 1 9 15.