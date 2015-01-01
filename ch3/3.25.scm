; Generalizing one and two dimensional tables, show how to implement a table in which values are stored under an arbitrary number of keys
; and different values may be stored under different numbers of keys. The lookup and insert! procedures should take as input a list of keys 
; used to access the table.
; =============
; We'll go with the version of make-table we used in 3.24. The main change is to switch key-1 and key-2 over to keys. If there is one
; key remaining, we know that it corresponds to the value we have to return or insert. Otherwise, it's a table.
;
; Oh, and we'll also have to track which table we're looking up in for the recursive lookup/insert calls, se we'll add a parameter to 
; each (could do local state for each, but that gets a bit messy)
;
; And now that lookup and insert! take a table parameter, they don't need to be part of the local state that maintains our local-table
; pointer, so we'll move them up in make-table (could even move them outside make-table if we wanted).
;
; Also, once we start storing values with different numbers of keys we run into a lookup issue where we mistake a value for a subtable.
; Say we have value V stored under key K. If we then try to look up a value for keys K and L, we get an error. This happens beacuse the 
; lookup for K finds V. If we actually had a value stored under K and L, this would be a subtable and we'd be able to pass it to 
; assoc and expect everything to work find. But V isn't a table, so when assoc tries to find the caar, it errors out. We need a way 
; to distinguish between these cases. We can't examine V and determine based on it's structure whether it is a table. At most we can 
; tell whether it could be a table (e.g. its cdr is a pair) because we could, afterall, store table-like structures without 
; intending them to be part of the lookup.
;
; To remedy this, we add a flag to the table, after its key: *table-struct*. We strip this off before passing it to assoc but leave
; it on everywhere else so we can distinguish between records and tables, using is-table? predicate.

(define (make-table same-key?)
    (define (assoc key records)
        (cond ((null? records) false)
              ((same-key? (caar records) key) (car records))
              (else (assoc key (cdr records)))))
    (define (add-to-table! record table)
        (set-cdr! (cdr table) (cons record (cddr table))))

    (define (is-table? t)
        (if (not (pair? t))
            false
            (eq? (car t) '*table-struct*)))

    (define (lookup keys table)
        (let ((entry (assoc (car keys) (cddr table))))  ; switch subtable to entry since it could be a table or record
            (if entry
                (if (null? (cdr keys)) ; no more keys
                    (cdr entry)
                    (if (is-table? (cdr entry))
                        (lookup (cdr keys) entry)
                        false))
                false)))

    (define (insert! keys value table)
        (let ((entry (lookup (list (car keys)) table))) ; look up entry next level down
            (if entry
                (if (null? (cdr keys))
                    (set-cdr! entry value)            ; update entry  using car keys and value
                    (insert! (cdr keys) value entry)) ; entry is a table, so insert into that with remaining keys
                (if (null? (cdr keys))
                    (add-to-table! (cons (car keys) value) table) ; add new value to table
                    (let ((new-table (list (car keys) '*table-struct*)))
                        (add-to-table! new-table table)
                        (insert! (cdr keys) value new-table)))))
        'ok)
    (let ((local-table (list '*table* '*table-struct*)))
        (define (dispatch m)
            (cond ((eq? m 'lookup-proc) 
                    (lambda (keys) (lookup keys local-table)))
                  ((eq? m 'insert-proc!) 
                    (lambda (keys val) (insert! keys val local-table)))
                  ((eq? m 'show) (display local-table))))
        dispatch))


; Here it is in action, finding (or not finding) what we put (or didn't put) in the table, as expected
1 ]=> (define b (make-table equal?))
1 ]=> ((b 'insert-proc!) (list 'a) 'b)
;Value: ok
1 ]=> ((b 'insert-proc!) (list 'b) 'c)
;Value: ok
1 ]=> ((b 'insert-proc!) (list 'c) 'd)
;Value: ok
1 ]=> ((b 'insert-proc!) (list 'w 'x 'y) 'z)
;Value: ok
1 ]=> ((b 'insert-proc!) (list 1 2 3) (list 4 5))
;Value: ok
1 ]=> ((b 'insert-proc!) (list 6 7 8 9) (list 10 11 12))
;Value: ok
1 ]=> ((b 'lookup-proc) (list 'a))
;Value: b
1 ]=> ((b 'lookup-proc) (list 'b))
;Value: c
1 ]=> ((b 'lookup-proc) (list 'c))
;Value: d
1 ]=> ((b 'lookup-proc) (list 'd))
;Value: #f
1 ]=> ((b 'lookup-proc) (list 'w 'x 'y))
;Value: z
1 ]=> ((b 'lookup-proc) (list 1 2 3))
;Value 260: (4 5)
1 ]=> ((b 'lookup-proc) (list 1 2 3 4))
;Value: #f
1 ]=> ((b 'lookup-proc) (list 6 7 8 9))
;Value 261: (10 11 12)



