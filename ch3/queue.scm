(define (front-ptr q) (car q))
(define (rear-ptr q) (cdr q))
(define (set-front-ptr! q item) (set-car! q item))
(define (set-rear-ptr! q item) (set-cdr! q item))
(define (empty-queue? q) (null? (front-ptr q)))
(define (make-queue) (cons '() '()))
(define (front-queue q)
    (if (empty-queue? q)
        (error "FRONT callsed with an empty queue" q)
        (car (front-ptr q))))
(define (insert-queue! q item)
    (let ((new-pair (cons item '())))
        (cond ((empty-queue? q)
                (set-front-ptr! q new-pair)
                (set-rear-ptr! q new-pair)
                q)
            (else 
                (set-cdr! (rear-ptr q) new-pair)
                (set-rear-ptr! q new-pair)
                q))))
(define (delete-queue! q)
    (cond ((empty-queue? q)
            (error "DELETE! called with an empty queue" q))
        (else (set-front-ptr! q (cdr (front-ptr q)))
            q)))


(define (make-queue)
    (let ((front-ptr '())
          (rear-ptr '()))
        (define (printable-queue) front-ptr)
        (define (empty-queue?) (null? front-ptr))
        (define (front-queue)
            (if (empty-queue?)
                (error "FRONT callsed with an empty queue" (printable-queue))
                (car front-ptr)))
        (define (insert-queue! item)
            (let ((new-pair (cons item '())))
                (cond ((empty-queue?)
                        (set! front-ptr new-pair)
                        (set! rear-ptr new-pair)
                        (printable-queue))
                    (else 
                        (set-cdr! rear-ptr new-pair)
                        (set! rear-ptr new-pair)
                        (printable-queue)))))
        (define (delete-queue!)
            (cond ((empty-queue?)
                    (error "DELETE! called with an empty queue" (printable-queue)))
                (else (set! front-ptr (cdr front-ptr))
                    (printable-queue))))
        (define (dispatch m)
            (cond
                ; ((eq? m 'front-ptr) front-ptr)  ; we don't need to expose these (though we did for the other representation)
                ; ((eq? m 'rear-ptr) rear-ptr)
                ; ((eq? m 'set-front-ptr!) set-front-ptr!)
                ; ((eq? m 'empty-queue?) empty-queue?)
                ((eq? m 'front-queue) front-queue)
                ((eq? m 'insert-queue!) insert-queue!)
                ((eq? m 'delete-queue!) delete-queue!)
                ((eq? m 'print-queue) (display (printable-queue)))
                (else (error "Did not recognize queue operation -- MAKE-QUEUE" (list m (printable-queue))))))
        dispatch))