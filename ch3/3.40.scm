; Give all possible values of x that can result from executing

; (define x 10)

; (parallel-execute (lambda () (set! x (* x x)))    ; P1
;                   (lambda () (set! x (* x x x)))) ; P2

; Which of these possibilities reamin if we instead use serialized procedures:

; (define x 10)
; (define s (make-serializer))
; (parallel-execute (s (lambda () (set! x (* x x))))
;                   (s (lambda () (set! x (* x x x)))))
; =========
; The result depends on which procedure sets x first and when it does so relative to the other.
;
; We'll start with the easy cases, where each completes atomically:
; - P1 completes before P2 starts: P1 sets x to 100, P2 sets x to 1,000,000. 
; - P2 cmopletes before P1 starts: P2 sets x to 1000, P1 sets x to 1,000,000.
; 
; Now let's consider what happens if P1 sets x while P2 is still evaluating. What happens depends on how many of the x references
; P2 has resolved 
;
; - P1 sets x to 100. P2 has already resolved all x references and sets x to (* 10 10 10), or 1000.
; - P1 sets x to 100. P2 has resolved two x references to 10, and gets 100 for the remaining one: (* 100 10 10). P2 sets x to 10,000
; - P1 sets x to 100. P2 has resolved one x reference to 10 and gets 100 for the remaining two: (* 100 100 10). P2 sets x to 100,000
; The remainign case (P2 hasn't resolved any x references) is identical to the no interleaving case.
;
; Similarly, if P2 sets x to 1000 before P1 has finished we get the following cases:
; - P1 has evaluated all x references to 10, so it sets x to 100
; - P1 has evaluated one x reference to 10, so it sets x to 10,000, (* 1000 10)
;
; If we serialize the procedures, we prevent these interleaving issues and will always get 1,000,000. (Since our expressions are 
; pure multiplication, the order of P1 and P2 don't matter.)

