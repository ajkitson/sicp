; Which of the five possibilities in the parallel execution shown above remain if we instead serialize execution as follows:
;
; (define x 10)
; (define s (make-serializer))
; (parallel-execute (lambda () (set! x ((s (lambda () (* x x))))))
;                   (s (lambda () (set! x (+ x 1)))))
;
; ==============
; We have the scenario where the two expressions to not interfere, but with different outcomes depending on the order:
; P1 completes, then P2 completes: 10 * 10 = 100, 100 + 1 = 101
; P2 completes, then P1 completes: 10 + 1 = 11, 11 * 11 = 121
;
; There is one more case, caused by moving the serialization inside the lambda for P1. In P1, we garauntee only that x will not
; change while evaluating (* x x). However, we do not gaurantee that x will not change between evaluating (* x x) and setting x.
; So we must also consider this scenario:
; P1 evaluates (* x x) to be 100 (the serialized bit of P1)
; P2 completes, setting x to 11
; P1 sets x to 100 and overwrites P2's value

