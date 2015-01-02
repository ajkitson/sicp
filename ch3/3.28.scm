; Define an or-gate as a primitive function box. Your or-gate constructor should be similar to and-gate
; =======
; Code is below. There's so much we haven't implemented yet (after-delay, get-signal, set-signal, or-gate-delay, add-action!) that
; there's not much to test right now. Looks like we implement all this over the next few pages--will circle back.

(define (or-gate input-1 input-2 output)
    (define (or-action-procedure)
        (let ((new-value 
                (logical-or (get-signal input-1) (get-signal input-2))))
            (after-delay or-gate-delay
                (lambda ()
                    (set-signal! output new-value)))))
    (add-action! input-1 or-action-procedure)
    (add-action! input-2 or-action-procedure)
    'ok)

(define (logical-or a b)
    (cond 
        ((= a 1) true)
        ((= b 1) true)
        (else false)))