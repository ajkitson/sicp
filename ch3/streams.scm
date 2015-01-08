
(define (stream-car s) (car s))
(define (stream-cdr s) (force (cdr s)))

(define (stream-ref s n)
    (if (= n 0)
        (stream-car s)
        (stream-ref (stream-cdr s) (- n 1))))

; (define (stream-map proc s)
;     (if (stream-null? s)
;         the-empty-stream
;         (cons-stream 
;             (proc (stream-car s))
;             (stream-map proc (stream-cdr s)))))

(define (stream-map proc . argsstream)
    (if (stream-null? (car argsstream))
        the-empty-stream
        (cons-stream
            (apply proc (map (lambda (s) (stream-car s)) argsstream))
            (apply stream-map
                   (cons proc (map (lambda (s) (stream-cdr s)) argsstream))))))


(define (stream-for-each proc s)
    (if (stream-null? s)
        'done
        (begin
            (proc (stream-car s))
            (stream-for-each proc (stream-cdr s)))))

(define (stream-enumerate-interval low high)
    (if (> low high)
        the-empty-stream
        (cons-stream
            low
            (stream-enumerate-interval (+ low 1) high))))

(define (stream-filter pred s)
    (if (stream-null? s)
        the-empty-stream
        (if (pred (stream-car s))
            (cons-stream (stream-car s) 
                         (stream-filter pred (stream-cdr s)))
            (stream-filter pred (stream-cdr s)))))

(define (add-streams s1 s2)
    (stream-map + s1 s2))
    ; (stream-map (lambda (a b) (newline)(display "*")(+ a b)) s1 s2))

(define (mul-streams s1 s2)
    (stream-map * s1 s2))

(define (scale-stream s factor)
    (stream-map (lambda (x) (* x factor)) s))

(define (display-stream s)
    (stream-for-each display-line s))

(define (display-line x)
    (newline)
    (display x))

(define (display-n-elems n s)
    (if (and (> n 0) 
             (not (stream-null? s)))
        (begin 
            (display-line (stream-car s))
            (display-n-elems (- n 1) (stream-cdr)))))

;; special-purpose streams
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1))))
; (define integers (integers-starting-from 1))
(define (divisible? x y) (= (remainder x y) 0))
(define (fibgen a b)
    (cons-stream a (fibgen b (+ a b))))
(define (fibs) (fibgen 0 1))

(define (seive s)
    (cons-stream
        (stream-car s)
        (seive (stream-filter (lambda (x) (not (divisible? x (stream-car s)))) (stream-cdr s)))))
(define primes (seive (integers-starting-from 2)))
(define ones (cons-stream 1 ones))
(define integers (cons-stream 1 (add-streams ones integers)))
(define double (cons-stream 1 (scale-stream double 2)))

