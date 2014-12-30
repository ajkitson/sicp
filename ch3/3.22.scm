; Instead of representing a queue as a pair of pointers, we can build a queue as a procedure with local state. The local state will consist
; of pointers to the beinning and end of an ordinary list. Thus, the make-queue procedure will have the form:
;
; (define (make-queue)
;     (let ((front-ptr ...)
;           (rear-ptr ...))
;       <definitions of internal procedures>
;       (define (dispatch m) ...)
;       dispatch))
;
; Complete the definition of make-queue and provide implementation s of the queue operations using this representation.
; ============
; We start out with front-ptr and rear-ptr pointing to empty lists. We should then be able to use most of the code we already in the text.
; We just need to update it to not lookup based on the queue (because we already have it in our local state) or need to look up front-ptr
; or rear-ptr. Then wire it into the dispatch system.

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

; This works well enough, but it's a bit awkward to interact with. When we have an argument to pass, as with insert-queue!, it's 
; natural enough:

1 ]=> (define q (make-queue))
1 ]=> ((q 'insert-queue!) 'first)
;Value 58: (first)
1 ]=> ((q 'insert-queue!) 'second)
;Value 58: (first second)

; But of the methods that don't take arguments, you have to retrieve the procedure and then call it, which just feels odd:
1 ]=> ((q 'front-queue))
;Value: first
1 ]=> ((q 'delete-queue!))
;Value 59: (second)
1 ]=> ((q 'delete-queue!))
;Value: ()

; We'll live the it since it'd be inconsistent to call the procedure, which would introduce its own problems. But still...




