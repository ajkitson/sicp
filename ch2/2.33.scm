; Fill in the missing expressions to complete the following definitions of some basic list-manipulation operations as accumulations:

; (define (map p sequence)
; 	(accumulate (lambda (x y) <??>) nil sequence))

; (define (append seq1 seq2)
; 	(accumulate cons <??> <??>))

; (define (length sequence)
; 	(accumulate <??> 0 sequence))
; =====
; Here's the definition of accumulate:
(define (accumulate op initial sequence)
	(if (null? sequence)
		initial
		(op (car sequence) 
			(accumulate op initial (cdr sequence)))))

; So accumulate moves through each item in the sequence, using op to evaluate that item and fold it in with the value(s) of the
; evaluated items from the rest of the list.

(define (map p sequence)
	(accumulate 
		(lambda (x y) (cons (p x) y))  ; y is the rest of the processed version of the rest of the list, so just process x and stick it on the front
		(list)  ; because our scheme interpreter doesn't recognize nil
		sequence))

(define (append seq1 seq2)
	(accumulate cons seq2 seq1)) ; this works because accumulate is a recursive process and fully evaluates the last item in the list first 

(define (length sequence)
	(accumulate (lambda (x y) (+ y 1)) 0 sequence)) ; just add one, whatever the value is