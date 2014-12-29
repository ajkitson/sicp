; Draw the box-and-pointer diagrams to explain the effect of set-to-wow! on the structures z1 and z2 above.
; ====
; Here's the code for set-to-wow!:
(define (set-to-wow! x)
    (set-car! (car x) 'wow)
    x)

; And here are the definitions for z1 and z2:
(define x (list 'a 'b))
(define z1 (cons x x))
(define z2 (cons (list 'a 'b) (list 'a 'b)))

(set-to-wow! z1)
((wow b) wow b)

(set-to-wow! z2)
((wow b) a b)

; Here are the box-and-pointer diagrams before set-to-wow!:
z1 --> @ @
       | |
x ---> @ @ --> @ X
       |       |
       a       b

z2 --> @ @ --> @ @ --> @ X
       |       |       |
       |       a       b       
       |       |       |
       '-----> @ @ --> @ X

; And now let's look at after. 
z1 --> @ @
       | |
x ---> @ @ --> @ X
       |       |
      wow      b

z2 --> @ @ --> @ @ --> @ X
       |       |       |
       |       a       b       
       |               |
       '-----> @ @ --> @ X
               |
              wow

; As we can see with z1, because the pair represented by x is both the car and cdr of z1, updating the car of x impact both the car and
; cdr of z1.
; However, for z2, because the car and cdr are distinct pairs, we simply change the (car (Car z2)) to point to a different symbol