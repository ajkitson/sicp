; The following procedure for appending lists was introduced in section 2.2.1:

; (define (append x y)
; 	(if (null? x)
; 		y
; 		(cons (car x) (append (cdr x) y))))

; Append forms a new list by successively consing the elements of x onto y. The procedure append! is similar to append but it is a
; mutator rather than a constructor. It appends the lists by splicing them together, modifying the final pair of x so that its cdr is
; now y. (It is an error to cal append! with an empty x.)

; (define (append! x y)
; 	(set-cdr! (last-pair x) y)
; 	x)

; Here last-pair is a procedure that returns the last pair in its argument:

; (define (last-pair x)
; 	(if (null? (cdr x))
; 		x
; 		(last-pair (cdr x))))

; Consider the interaction:
; (define x (list 'a 'b))
; (define y (list 'c 'd))
; (define z (append x y))		

; z => (a b c d)
; (cdr x) => ????

; (define w (append! x y))

; w => (a b c d)
; (cdr x) = ????

; What are the values for (cdr x)? Draw box and pointer diagrams to explain your answer.
; =======
; In the first case, creating z with (append x y) does not modify x, so (cdr x) is the same as it would be before z is created, 
; i.e. (cdr x) => (b)
;
; In the second case, creating w with (append! x y) mutates x. x is now the list (a b c d), so (cdr x) => (b c d)

; Starting definitions of x and y for both cases:
x --> @ @ --> @ /
      |       |
      a       b 

y --> @ @ --> @ /
      |       |
      c       d 

; First case with append >> z is a separate structure!
x --> @ @ --> @ /
      |       |
      a       b 

y --> @ @ --> @ /
      |       |
      c       d 

z --> @ @ --> @ @ --> @ @ --> @ /
      |       |       |       |
      a       b       c       d

; And box and pointer for the second case, where append! mutates x and w points to the same structure as x:

w-----|
x --> @ @ --> @ @ -----|  ; the last pair of x now points to the same structure y does
      |       |        |
      a       b        |
       ________________|
      |                
y --> @ @ --> @ /
      |       |
      c       d 

; Note that y is still defined. In fact, changes to y will update x and w now:
1 ]=> (define x (list 'a 'b))
1 ]=> (define y (list 'c 'd))
1 ]=> (define w (append! x y))
1 ]=> w
;Value 10: (a b c d)
1 ]=> x
;Value 10: (a b c d)
1 ]=> y
;Value 11: (c d)
1 ]=> (set-car! y 'z)
1 ]=> w
;Value 10: (a b z d)
1 ]=> x
;Value 10: (a b z d)
1 ]=> y
;Value 11: (z d)

; Interesting--noticing now the "Value N" out put by the interpreter actually indicates which structure/value it points to, so
; that w and x both point to value 10.











