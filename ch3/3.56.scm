; A famous problem, first raised by R. Hamming, is to enumerate, in ascending order with no repetitions, all positive integers with no 
; prime factors other than 2, 3, or 5. One obvious way to do this is to simply test each integer in turn to see whether it has any factors
; other than 2, 3, or 5. But this is very inefficient, since, as the integers get larger, fewer and fewer of them fit the requirement.
; As an alternative, let us call the required stream of numbers S and notice the following facts about it.
;
; - S begins with 1
; - The elements of (scale-stream S 2) are also elements of S.
; - The same is true for (scale-stream S 3) and (scale-stream S 5).
; - These are all the elements of S.
;
; Now all we have to do is combine elements from these sources For this we define a procedure merge that combines two ordered streams
; into one ordered ressult stream eliminating repetitions:
;
; (define (merge s1 s2)
;     (cond 
;         ((stream-null? s1) s2)
;         ((stream-null? s2) s1)
;         (else
;             (let ((s1car (stream-car s1))
;                   (s2car (stream-car s2)))
;                 (cond 
;                     ((< s1car s2car)
;                         (cons-stream s1car (merge (stream-cdr s1) s2)))
;                     ((> s1car s2car)
;                         (cons-stream s2car (merge s1 (stream-cdr s2))))
;                     (else 
;                         (cons-stream s1car (merge (stream-cdr s1) (stream-cdr s2)))))))))
;
; Then the required stream may be constructed with merge as follows:
;
; (define S (cons-stream 1 (merge ?? ??)))
;
; Fill in the missing expressions in the places marked ?? above.
; ======
; This was one where I had working code before I understood how it worked. My big questions was how we exclude certain numbers. Some 
; numbers we skip over are obvious. For example, 7 isn't a multiple of 2, 3, or 5 so of course we don't include it. But why do we
; exclude 14? After all, it's a multiple of 2. I can see by the definition of the sequence that we don't want to include it (since it 
; has a prime factor of 7), but couldn't figure out the mechanism in the code that would cause 14 to be excluded. And yet it was.

; Here's the code:
(define S 
    (cons-stream 1 
                 (merge (scale-stream S 2) 
                        (merge (scale-stream S 3) (scale-stream S 5)))))


; Here it is in action:
1 ]=> (stream-for-each (lambda (n) (display-line (stream-ref S n))) (stream-enumerate-interval 1 20))

2
3
4
5
6
8
9
10
12
15
16
18
20
24
25
27
30
32
36
40
;Value: done

; You can see that we skip primes like 7 and 13, and that we skip multiples of these primes, like 14 and 26.
; To understand how 14 and 26 are included, we need to understand how S generates itself--actually builds itself up.
;
; I made two mistakes in thinking about S. First, I thought of it as just the integers, so that (scale-stream S 2) would count 
; by twos. But that's incorrect--think about the self-referential definition and you see that it's not right. S is itself scaled
; by two.
;
; This led to my second mistake in thinking about it--that it would be powers of 2, combined with powers of 3, combined with 
; powers of 5. That, afterall, is what each (scale-stream S n) call produces. But it doesn't match out output.
;
; The key was groking that the streams building themselves as they go. It's not merging pre-combuted powers of 2, 3, and 5. Rather,
; these steams scale S as it grows, and, in turn, S grows as these streams do--it's a back and forth.
;
; We're building out four different streams in concert: S, and S scaled to 2, 3, and 5. We calculate the scaled streams only
; as we pull off the front value of a given stream (e.g. we only calculate the next value in S scaled 5 when we pull 5 off the front).
; Because there's this delay, when the S-scaled-5 stream goes to generate its next value, it sees the other numbers put on S but 
; the other scaled streams and scales those as well.
; 
; Snapshots
; S: 1 ....     S:  1 2...    S:  1 2 ...      S:  1 2 3 ...    S:  1 2 3 4 ...     S:  1 2 3 4 5 ...  S:  1 2 3 4 5 6 ...
; S2: ...       S2: 2 ...     S2: 2 4...       S2: 2 4 ...      S2: 2 4 6 ...       S2: 2 4 6 ...      S2: 2 4 6 8...
; S3: ...       S3: 3 ...     S3: 3 ...        S3: 3 6 ...      S3: 3 6 ...         S3: 3 6 ...        S3: 3 6 9 ...
; S5: ...       S5: 5 ...     S5: 5 ...        S5: 5 ...        S5: 5 ...           S5: 5 10 ...       S5: 5 10 ...

; In this way, the scaled streams are built out at the same time as the stream that they are scaling, each getting built as it
; contributes to S (which is why the S-scaled-5 grows more slowly).


