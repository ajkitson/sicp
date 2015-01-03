; The celsius-farenheit converter procedure is cumbersome when compared with a more expression oriented style of definition, such as:

(define (celsius-farenheit-converter x)
    (c+ (c* (c/ (cv 9) (cv 5))
            x)
        (cv 32)))

; (define C (make-connector))
; (define F (celsius-farenheit-converter C))        

; Here c+, c*, etc are the "constraint" versions of the arithmetic operations. For example, c+ takes two connectors as arguments and 
; returns a connector that is related to these by an adder constraint:

; (define (c+ x y)
;     (let ((z (make-connector)))
;         (adder x y z)
;         z))

; Define analogous procedures c-, c*, c/, and cv (constant value) that anable us to define compound constraints as in the converter 
; example above.
; ===========
; 

(define (c* x y)
    (let ((z (make-connector)))
        (multiplier x y z)
        z))

(define (c/ x y)
    (let ((z (make-connector)))
        (divider x y z)
        z))

(define (c- x y)
    (let ((z (make-connector))
          (m (make-connector)))
        (multiplier y (cv -1) m) ; m is y * -1
        (adder x m z)
        z))

(define (cv val)
    (let ((z (make-connector)))
        (constant val z)
        z))


; In action:

1 ]=> (define Cel (make-connector))
1 ]=> (define F (celsius-farenheit-converter Cel))
1 ]=> (set-value! F 212 'andy)
;Value: done
1 ]=> (get-value Cel)
;Value: 100
1 ]=> (forget-value! F 'andy)
;Value: done
1 ]=> (set-value! Cel 0 'andy)
;Value: done
1 ]=> (get-value F)
;Value: 32


