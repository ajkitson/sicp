; In order to take a closer look at delayed evaluation, we will use the following procedure, which simply returns its argument after 
; printing it:

; (define (show x)
;     (display-line x)
;     x)

; What does the interpreter print in response to evaluating each experssion in the following sequence?

; (define x (stream-map show (stream-enumerate-interval 0 10)))

; (stream-ref x 5)

; (stream-ref x 7)
; ======
; We'll do the old guess and check method here.
; Let's see, for defining x...
;
; - stream-enumerate-interval will evaluate to (0 . (stream-enumerate-interval (+ 0 1) 10))
; - stream-map will:
;   - run show on 0, so will display 0  (and include 0 in our new stream)
;   - return the stream (0 . (stream-map show (stream-enumerate-interval (+ 0 1) 10))) //a bit of fudging on the stream we pass to stream-map
; 
; So in defining x, the intrepreter will display 0.
; Then in evaluating (stream-ref x 5), we run show over 0, 1, 2, 3, 4 (each of these becomes the car as we traipse down the stream to find index 5)
; And similarly for (stream-ref x 7), we run show over 0, 1, 2, 3, 4, 5, 6
;
; Let's see if I'm right:
1 ]=> (define x (stream-map show (stream-enumerate-interval 0 10)))
0
;Value: x

1 ]=> (stream-ref x 5)
1
2
3
4
5
;Value: 5

1 ]=> (stream-ref x 7)
6
7
;Value: 7

; INTERESTING! I was wrong, and in two ways. First, I had an off-by-one error. Because the interval started at zero, values match up 
; with their index--simple oversight I should have caught (and did in testing :).
;
; The more interesting one is (stream-ref x 7). This must be the result of the memoization we do on the delay procedure. Instead of 
; calculating the values over again (which would "show" them--i.e. print to the interpreter), we just get the previously computed
; values for 1 - 5, and only have to compute 6 and 7, so that's why only they are displayed. (You can also see this in (stream-ref x 5) 
; in that we don't print 0 there either).
;
; The deeper point that this re-inforces is that as we traverse the stream, we create an environment structure that persists (thanks
; to the memoization). The first time we force the delayed procedure in stream-cdr, we create the environment structure and (often)
; a new stream-cdr with a new delayed procedure. When we force the procedure again, we re-use the same environment structure, which 
; means that the definition of the delayed procedure in the new stream-cdr IS THE SAME DEFINITION as in the first call... and so on down
; the chaoin. The memoization discussioon in the book had me puzzled, and this helped enormously.


