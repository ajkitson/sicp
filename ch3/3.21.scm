; Ben Bitdiddle  decides to test the queue implementation  described above. He types in the procedures to the Lisp interpreter and proceeds 
; to try them out:

; (define q1 (make-queue))

; (insert-queue! q1 'a)
; ((a) a)

; (insert-queue! q1 'b)
; ((a b) b)

; (delete-queue! q1)
; ((b) b)

; (delete-queue! q1)
; (() b)

; "It's all wrong!" he complains. "The interpreter's response shows that the last item is inserted into the queue twice. And when I delete
; both items, the second b is still there so the queue isn't empty, even though it's supposed to be." Eva Lu Ator sugggests that Ben has
; misunderstood what is happening. "It's not that the items are going into the queue twice," she exlains. "It's just that the standard
; Lisp printer doesn't know how to make sense of the queue representation. If you want to see the queue printed correctly, you'll have
; to define your own print procedure for queues." Explain what Eva Lu Is talking about. In particular, show why Ben's examples produce
; the printed results they do. Define a procedure print-queue that takes a queue as input and prints the sequence of items in the queue.
; =======
; Ben's mixup seems to be forgetting that we set up the queue representation as a pair consisting of a pointer to the front of the list
; that contains all the elements and a pointer to the last element in that list. When the standard Lisp printer sees this, it prints
; out a pair consisting of the entire list (or queue) and the last element in the list. But these are just two views into the same queue,
; and it's the first that we rely on for determining whether there are any elements in the queue and what elements those are. So if the
; front pointer points to the empty list, then the queue is empty.
;
; To print out the queue, we can just print the list that the front pointer refers to:

(define (print-queue q)
    (display (front-ptr q)))

; Now if we try the queue as Ben did, we can use print-queue to see the elements that are actually in the queue:
1 ]=> (define q1 (make-queue))
1 ]=> (print-queue q1)
()
1 ]=> (insert-queue! q1 'a)
;Value 53: ((a) a)
1 ]=> (print-queue q1)
(a)
1 ]=> (insert-queue! q1 'b)
;Value 53: ((a b) b)
1 ]=> (print-queue q1)
(a b)
1 ]=> (delete-queue! q1)
;Value 53: ((b) b)
1 ]=> (print-queue q1)
(b)
1 ]=> (delete-queue! q1)
;Value 53: (() b)
1 ]=> (print-queue q1)
()





