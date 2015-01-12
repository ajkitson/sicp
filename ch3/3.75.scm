; Unfortunately, Alyssa's zero-crossing detector in exercise 3.74 proves to be insufficient, because the noisy signal from the sensor leads
; to spurious zero crossings. Lem E. Tweakit, a hardware specialist, suggests that Alyssa smooth the signal to filter out the noise before
; extracting the zero crossings. Alyssa takes his advice and decides to extract the zero crossings from the signal constructed by averaging
; each value of the sensor data with the previous value. She explains the provlem to her assistant, Louis Reasoner, who attempts to 
; implement the idea, altering Alyssa's program as follows:

; (define (make-zero-crossings input-stream last-value)
;     (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
;         (cons-stream
;             (sign-change-detector avpt last-value)
;             (make-zero-crossings (stream-cdr input-stream)
;                                  avpt))))

; This does not correctly implement Alyssa's plan. Find the bug that Louis has installed and fix it without changing the structure
; of the program. (Hint: You will need to increase the number of arguments to make-zero-crossings).
; ======
; There are a couple issues. First, Alyssa wants both values fed to sign-change-detector to be averaged with their respective previous
; values. Louis currently is passing (1) the average of the current value and previous (good!) and (2) the unaveraged last value (uh oh!). 
; That's not the comparison she asked for.
; 
; Or that's sort of what he's doing. But not quite. That's what he would be doing if he hadn't made the second error. Instead of passing 
; the actual last value as the second param to make-zero-crossings, he's passing the average stored in avpt. Now, because he's feeding 
; this back to make-zero-crossings as the last-value, avpt is not actually an average of the current value and the previous one. 
; Rather, it's the running average of each value with all previous values. 
;
; So let's fix it. We'll add a parameter to strack the last average. We'll use last-value to compute the current average and last-avpt
; along with avpt to figure out whether we had a zero-crossing. 

(define (make-zero-crossings input-stream last-value last-avpt)
    (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
        (cons-stream
            (sign-change-detector avpt last-avpt)
            (make-zero-crossings (stream-cdr input-stream)
                                 (stream-car input-stream)
                                 avpt))))

