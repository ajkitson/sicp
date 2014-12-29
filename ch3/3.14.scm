; The following procedure is quite useful, although obscure:
;
; (define (mystery x)
;     (define (loop x y)
;         (if (null? x)
;             y
;             (let ((temp (cdr x)))
;                 (set-cdr! x y)
;                 (loop temp x))))
;     (loop x '()))
;
; Loop uses the "temporary" variable temp to hold the old value of the cdr of x, since the set-cdr! on the next line destroys the cdr.
; Explain what mystery does in general. Suppose v is defined by (define v (list 'a 'b 'c 'd)). Draw the box and pointer diagram that
; represents the list to which v is bound. Suppose that we now evalutate (define w (mystery v)). Draw box and pointer diagrams that
; show the sutrcutes v and w after evalutating this expression. What would be printed as the values of v and w?
; ======
; I had to stare at it for awhile, but I'm pretty sure that mystery reverses a list. You can see that on each iteration of the 
; loop, we take the first element from x and add it to y. The way it does this is a bit obscure. Loop sets the cdr of x to y,
; which creates a list that's just like y, but now with the first element on the front. It then passes this updated x as the 
; second argument to loop, so it is now y on the next iteration and the new value of x is just the cdr of the old value of x.
;
; Let's see if this is right"
1 ]=> (define v (list 'a 'b 'c 'd))
1 ]=> v
1 ]=>  (mystery v)
;Value 14: (d c b a)

; Here's the box-and-pointer diagram for v:

v --> @@ --> @@ --> @@ --> @X
      |      |      |      |
      a      b      c      d

; Here's the first pass through loop:
; y starts as the empty list
y --> XX

; we define temp to be the cdr of x:
temp --------|
x --> @@ --> @@ --> @@ --> @X
      |      |      |      |
      a      b      c      d

; then we set the cdr of x to y (the empty list), meanwhile temp maintains it's pointer to what was the cdr of x
temp --------|
x --> @@ -,  @@ --> @@ --> @X
      |   |  |      |      |
      a   |  b      c      d
      ____|
      |
y --> XX

; then on the next call to loop, temp is our new x and x is our new y:

x --> @@ --> @@ --> @X
      |      |      |
      b      c      d

y --> @X 
      |
      a

; And then ew do the process again, defining temp and setting cdr of x to y:
temp --------|
x --> @@ -,  @@ --> @X
      |   |  |      |
      b   |  c      d
      ,___| 
      |
y --> @X 
      |
      a

; So that on the next call, we have 
x --> @@ --> @X
      |      |
      c      d

y --> @@ --> @X 
      |      |
      b      a

; And we continus this until we have reversed the entire thing.



