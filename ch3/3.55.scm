; Define a procedure partial-sums that takes as argument a stream S and retuerns the stream who elements are S0, S0 + S1, 
; S0 + S1 + S2,... For example, (partial-sums integers) should be the stream 1, 3, 6, 10, 15
; ======
; Interesting. Basically, what we have here, is the combination of two streams: (cdr s) and (partial-sum s). 

(define (partial-sums s)
    (cons-stream (stream-car s)
                 (add-streams (stream-cdr s) 
                              (partial-sums s))))

; Here's how it works on integers:
1 ]=> (define p (partial-sums (stream-enumerate-interval 1 20)))
1 ]=> (display-stream p)

1
3
6
10
15
21
28
36
45
55
66
78
91
105
120
136
153
171
190
210
;Value: done

; And on just the even numbers:
1 ]=> (define p (partial-sums (stream-filter even? (stream-enumerate-interval 1 20))))
1 ]=> (display-stream p)

2
6
12
20
30
42
56
72
90
110
;Value: done
