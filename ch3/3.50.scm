; Complete the following definition, which generalizes stream-map to allow procedures that take multiple arguments, analogous to map in
; section 2.2.3, footnote 12.

; (define (stream-map proc . argsstream)
;     (if (?? (car argsstream))
;         the-empt-stream
;         (??
;             (apply proc (map ?? argsstream))
;             (apply stream-map
;                    (cons proc (map ?? argsstream))))))
;
; ============
; Nothing exciting here, just some practice using the stream-specific versions of our list operations

(define (stream-map proc . argsstream)
    (if (stream-null? (car argsstream))
        the-empty-stream
        (cons-stream
            (apply proc (map (lambda (s) (stream-car s)) argsstream))
            (apply stream-map
                   (cons proc (map (lambda (s) (stream-cdr s)) argsstream))))))

; We'll simply sum two streams. Here's the normal list version first, followed by the stream version. Note that we need to use
; display-stream in order to see the full stream, which is why the output is formatted differently.

1 ]=> (map (lambda (a b) (+ a b)) (list 1 2 3 4 5) (list 6 7 8 9 10))
;Value 283: (7 9 11 13 15)

1 ]=> (display-stream (stream-map (lambda (a b) (+ a b)) (stream-enumerate-interval 1 5) (stream-enumerate-interval 6 10)))
7
9
11
13
15
;Value: done

