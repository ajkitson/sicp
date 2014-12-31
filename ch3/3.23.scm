; A deque ("double-ended queue") is a sequence in which items can be inserted and deleted at either the front or the rear. Operations on 
; deques are the constructor make-deque, the predicate empty-deque?, selectors front-deque and rear-deque, and mutators front-insert-deque!,
; rear-insert-deque!, front-delete-deque!, rear-delete-deque!. Show how to represent deques using pairs, and give implementations of the 
; operations. All operations should be accomplished in O(1) steps.
; ========
; How much different do we need to make this from the regular queue representation? Most of these operations would work fine in O(1) time
; with some slight modification. The challenging one is going to be rear-delete-deque! This is because, when we delete the last pair, we
; need to know what to set the rear-ptr to. But the last pair doesn't point back up the list to the previous pair, which is what the 
; rear-ptr should be set to when we delete the last pair. To find that pointer, we would either have to read through the list starting 
; from front-ptr, or maintain a separate list that's in reverse order and have the rear-ptr point to the front of that list and,
; of course, syncronize mutations of the lists. But when you get into how you would do the synchronization, you realize that you can't
; do it in O(1) time -- for one list or the other, you need to cycle through the whole thing to find the new last pair.
;
; The best I can think of is a doubly-linked list. In this representation, each entry in the list contains the value we're putting 
; into the queue and a pointer back to the previous item.
;
; q --> @ @ --> @ @ --> @ /
;       |  `\_  |  `\_  |
;     (/ a)   (@ b)   (@ c)
; 
; This way, when we delete the last pair, we can see which pair is the new rear-ptr by checking the back pointer. 
;
; This also helps us make sense of an odd footnote: "Be careful not to make the interpreter try to print a structure that contains cycles."
; This had me wondering since we hadn't worried about cycles with the previous queue implementations. There must be something about deques
; that makes a cycle likely or inevitable. At first, I thought maybe the entire list should be a cycle, with the last pair pointing 
; back to the first, but that didn't solve any of the issues we were having. But by storing a back pointer along with the value, we 
; will have a cycle in that if I print a value in the list, it will include the backpointer which will print the previous value and then
; back to the current value with the backpointer and then to the previous value again, etc.
;
; The other choice is whether to do a procedural or whatever-the-opposite-of-procedure-is implementation. I'll go with the standard,
; non-procedural one that we've been doing so far.

(define (make-deque)
    (cons '() '()))
(define (front-ptr dq)
    (car dq))
(define (rear-ptr dq)
    (cdr dq))
(define (set-front-ptr! dq ptr)
    (set-car! dq ptr))
(define (set-rear-ptr! dq ptr)
    (set-cdr! dq ptr))
(define (empty-deque? dq)
    (null? (front-ptr dq)))

(define (value elem)
    (car (car elem)))
(define (back-ptr elem)
    (cdr (car elem)))
(define (next-elem elem)
    (cdr elem))
(define (set-back-ptr! elem val)
    (set-cdr! (car elem) val))

(define (printable-deque dq) 
    (map (lambda (p) (car p)) (front-ptr dq))) ; can't use value here beceause map doesn't give use the complete pair, but the value/back-ptr node

(define (front-deque dq)
    (if (empty-deque? dq)
        (error "FRONT-DEQUE called on empty dq" dq)
        (value (front-ptr dq))))

(define (rear-deque dq)
    (if (empty-deque? dq)
        (error "REAR-DEQUE called on empty dq" dq)
        (value (rear-ptr dq))))

(define (rear-insert-deque! dq item)
    (let ((new-pair (cons 
                        (cons item (rear-ptr dq))  ; item + backpointer
                        '())))
        (cond 
            ((empty-deque? dq) 
                (set-rear-ptr! dq new-pair)
                (set-front-ptr! dq new-pair)
                (printable-deque dq))
            (else 
                (set-cdr! (rear-ptr dq) new-pair)
                (set-rear-ptr! dq new-pair)
                (printable-deque dq)))))

(define (front-insert-deque! dq item)
    (let ((new-pair (cons 
                        (cons item '()) ; no backpointer on front
                        (front-ptr dq))))
        (cond 
            ((empty-deque? dq)
                (set-front-ptr! dq new-pair)
                (set-rear-ptr! dq new-pair)
                (printable-deque dq))
            (else
                (set-back-ptr! (front-ptr dq) new-pair)
                (set-front-ptr! dq new-pair)
                (printable-deque dq)))))

(define (rear-delete-deque! dq)
    (cond 
        ((empty-deque? dq)
            (error "Called REAR-DELETE-DEQUE with empty dq" dq))
        (else 
            (let ((new-rear-ptr (back-ptr (rear-ptr dq))))
                (set-rear-ptr! dq new-rear-ptr)  ; move rear-ptr back an item
                (if (null? new-rear-ptr)
                    (set-front-ptr! dq '())       ; if new-rear-ptr is null, set front to null, too 
                    (set-cdr! new-rear-ptr '())) ; otheriwse, if new-rear-ptr not null, remove it's pointer to the old rear-ptr
                (printable-deque dq)))))

(define (front-delete-deque! dq)
    (cond ((empty-deque? dq)
            (error "Called FRONT-DELETE-DEQUE with empty dq" dq))
        (else (let ((new-front-ptr (cdr (front-ptr dq))))
                (if (not (null? new-front-ptr))        ; not empty 
                    (set-back-ptr! new-front-ptr '())) ; new front pointer needs null back pointer, in case we rear-delete from a one item dq
                (set-front-ptr! dq new-front-ptr) 
                (printable-deque dq)))))


; issue: rear-insert, front insert, rear-delete

; Alrighty, that was a bit messier than I expected it to be. If we end up doing more with deques I'll probably circle back and rewrite
; this in the procedural style--I'm not comfortable with how much state is floating around.

; It works in any case. You can build a deque from scratch from the front or rear and take it down to nothing, again from front or
; rear. The trickier parts were in handling the cases of going from one item to none.


; Here are some operations showing it in action
1 ]=> (define d (make-deque))
1 ]=> (front-insert-deque! d 'a)
;Value 229: (a)
1 ]=> (front-insert-deque! d 'b)
;Value 230: (b a)
1 ]=> (rear-insert-deque! d 'c)
;Value 231: (b a c)
1 ]=> (rear-insert-deque! d 'd)
;Value 232: (b a c d)
1 ]=> (rear-delete-deque! d)
;Value 233: (b a c)
1 ]=> (rear-delete-deque! d)
;Value 234: (b a)
1 ]=> (front-delete-deque! d)
;Value 235: (a)
1 ]=> (front-delete-deque! d)
;Value: ()




