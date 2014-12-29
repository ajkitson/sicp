; Ben Bitdiddle descides to write a procedure to count the number of pairs in any list structure. "It's easy," he reasons. "The number of
; pairs in any structure is the number in the car plus the number in the cdr plus one more to count the current pair." So Ben writes the 
; following procedure:
;
; (define (count-pairs x)
;     (if (not (pair? x))
;         0
;         (+ (count-pairs (car x))
;            (count-pairs (cdr x))
;            1)))
;
; Show that the procedure is not correct. In particular, draw box-and-pointer diagrams representing list structures made up of exactly three
; pairs for which Ben's procedure would return 3, return 4, return 7, and never return at all.
; =====
; Let's start by talking about when Ben's procedure is correct. It's correct of lists composed of entirely distinct elements.
; As long as we don't use assigment (composing lists with variables that point to the same structures, or updating lists with
; mutators), Ben's code is correct.
;
; So here's a case where count-pairs will count 3 pairs when given 3 pairs:

1 ]=> (count-pairs (list 1 2 3))
;Value: 3

; This has the standard box-and-pointer diagram:
x --> @ @ --> @ @ --> @ X
      |       |       |   
      1       2       3

; Now, it'll go wrong when we repeat elements in the list. count-pairs doesn't return at all if we give it one of the cyces we
; made earlier
1 ]=> (define a (make-cycle (list 1 2 3)))
1 ]=> (count-pairs a)
;Aborting!: maximum recursion depth exceeded

; Here's the box and pointer for the cycle:
a --> @@ --> @@ --> @@--,
   ^  |      |      |   |
   |  1      2      3   |
   |____________________|


; Now for 4, we can do something like this:
(define a (list 'a))
1 ]=> (count-pairs (cons 'b (cons a a)))
;Value: 4

; Here's the box-and-pointer:
x --> @ @ --> @ @---,
      |       |     |
      b       `---> @ X
                    |
                    a

; And for seven, we can do:
1 ]=> (define a (list 1))
1 ]=> (define b (cons a a))
1 ]=> (define c (cons b b))
1 ]=> (count-pairs c)
;Value: 7
c --> @ @
      |/
b --> @ @
      |/
a --> @ X
      |
      1

