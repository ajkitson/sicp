; The internal procedures in the scheme-number package are essentially nothing more than calls to the primitive procedures +, -, etc. 
; It was not possible to use the primitives of the language directly because our type-tag system requires that each data object have
; a type attached to it. In fact, however, all Lisp implementations do have a type system, which they use internally. Primitive predicates
; such as symbol? and number? determine whether data objects have particular types. Modify the definitions of type-tag, contents, and 
; attach-tag from section 2.4.2 so that our generic system takes advantage of Scheme's internal type system. That is to say, the system
; should work as before except that ordinary numbers should be represented as Scheme numbers rather than as pairs whose car is the 
; symbol scheme-number.
; =====
; I'm going to interpret this as still allowing apply-generic to look up the primitives by the scheme-number type. In that case, what
; we want to do is have type-tag return scheme-number if we have a number, contents do nothing if we have a number (i.e. don't strip
; the car) and attach-tag do nothing for a scheme number.

(define (attach-tag type-tag contents)
	(if (eq? type-tag 'scheme-number)  ; do this instead of number? check since other types *might* pass in numbers that should be tagged
		contents
		(cons type-tag contents)))

(define (type-tag datum)
	(cond 
		((number? datum) 'scheme-number)
		((pair? datum) (car datum))
		(else (error "Bad tagged datum -- TYPE-TAG" datum))))

(define (contents datum)
	(cond 
		((number? datum) datum)
		((pair? datum) (cdr datum))
		(else (error "Bad tagged datum -- CONTENTS" datum))))

; Here's what we get before making the above updates. Only tagged numbers work:
1 ]=> (add (make-scheme-number 3) (make-scheme-number 4))
;Value 51: (scheme-number . 7)
1 ]=> (add 3 4)
;Bad tagged datum -- TYPE-TAG 3



; And now after, regular numbers work:
1 ]=> (mul 4 5)
;Value: 20

1 ]=> (add 3 4)
;Value: 7

1 ]=> (div 20 5)
;Value: 4

1 ]=> (sub 50 30)
;Value: 20

; And this still works:
1 ]=> (add (make-scheme-number 3) (make-scheme-number 4))
;Value: 7


