; In the table implementations above, the keys are tested for equality using equal? (called by assoc). This is not always the appropraite
; test. For instance, we might have a table with numeric keys in which we don't need an exact matchto the number we're looking up, but only 
; a number within some tolerance of it. Design a table constructor make-table that takes as argument a same-key? procedure that will be used 
; to test "equality" of keys. make-table should return a dispatch procedure that can be used to access appropriate lookup and insert!
; procedures for a local table.
; =====
; We'll start by pulling together the table code and then will update it to take same-key? procedure. The main change I see is 
; going to be either adding assoc internally to make-table so it can reference same-key? via local state, or adding a parameter to
; assoc and then making use of that parameter. I'll go with moving assoc internal to make-table so it can share local state. If we 
; already had stuff outside the table relying on assoc, this would allow them to continue using their version without having to make 
; any changes.

(define (make-table same-key?)
    (define (assoc key records)
        (cond ((null? records) false)
              ((same-key? (caar records) key) (car records))
              (else (assoc key (cdr records)))))
    (let ((local-table (list '*table*)))
        (define (lookup key-1 key-2)
            (let ((subtable (assoc key-1 (cdr local-table))))
                (if subtable
                    (let ((record (assoc key-2 (cdr subtable))))
                        (if record
                            (cdr record)
                            false))
                    false)))
        (define (insert! key-1 key-2 value)
            (let ((subtable (assoc key-1 (cdr local-table))))
                (if subtable
                    (let ((record (assoc key-2 (cdr subtable))))
                        (if record
                            (set-cdr! record value)
                            (set-cdr! subtable
                                      (cons (cons key-2 value) ; pop on the front of the table 
                                            (cdr subtable)))))
                    (set-cdr! local-table   ;add new table
                              (cons (list key-1 (cons key-2 value))
                                    (cdr local-table)))))
            'ok)
        (define (dispatch m)
            (cond ((eq? m 'lookup-proc) lookup)
                  ((eq? m 'insert-proc!) insert!)))
        dispatch))

; We'll test a table that stores a multiplication table. If you look up using a non-integer value, it'll round down to an integer
; and return an answer for the integer. For example, 6.7 * 5.4 = 30.

; Here's the code to make the table:
(define (make-mul-table n)
    (define (round-down-eq? x y)
        (= (floor x) (floor y)))
    (let ((table (make-table round-down-eq?)))
        (define (fill-table r c)
            (cond
                ((<= c n)
                    ((table 'insert-proc!) r c (* r c))
                    (fill-table r (+ c 1)))
                ((<= r n)
                    (fill-table (+ r 1) 1))
                (else 'done)))
        (fill-table 1 1)
        table))

; Now let's create a table and try it out:
1 ]=> (define m (make-mul-table 10))
;Value: m
1 ]=> ((m 'lookup-proc) 4 5)
;Value: 20
1 ]=> ((m 'lookup-proc) 4 10)
;Value: 40
1 ]=> ((m 'lookup-proc) 6 10)
;Value: 60

; Now let's try with non-integers and see if the rounding works:
1 ]=> ((m 'lookup-proc) 6.1 10.9)
;Value: 60
1 ]=> ((m 'lookup-proc) 3.8 7.2)
;Value: 21

; It does! 







