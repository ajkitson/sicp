; A semaphore (of size n) is a generalization of a mutex. Like a mutex, a semaphore supports acquire and release operations, but it is more
; general in that up to n processes can acquire it concurrently. Additional processes that attempt to acquire the semaphore must wait for release
; operations. Give implementations fo semaphores
;
; a. in terms of mutexes
; b. in terms of atomic test-and-set! operations
; =========
; It's not entirely clear to me what "in terms of" entails. I'll take it to mean "composed of", so that the mutex version just uses
; a set of mutexes and isn't aware of the test-and-set! operation that the mutex relies on, and the test-and-set! version explores
; what we can do if we allow the semaphore access to that lower abstraction level.
;
; We'll start with the mutexes. We could simply have an n-sized list of mutexes that we dole out as processes request them. We'll allow
; the mutex to handle any waiting that the process needs to do. This means that we want to make sure that we're giving the process a free
; mutex--one that can actually be acquired--when we hand them out. 
; 
; Since our mutex doesn't have an aquirable? predicate, we'll have to track this ourselves. At first I thought we could do two lists,
; one of mutexes that are free and the other of mutexes that are being used. We would pull from the free list and put it in the used
; list until the process was done with it, at which point we move it back to the free list. But the problem with this is what happens
; when all the mutexes are in use. Part of the advantage of using mutexes has got to be that they handle making a process wait to 
; acquire the mutex. But if we only give mutexes from the free list, then once all the mutexes are handed out we don't have anything 
; to do when more processes ask for one. We could pull from the in-use list... but that undermines the whole point of having two separate
; lists.
;
; Instead, we'll track our mutexes in a deque. When we acquire a mutex, we pull it off the front of the queue and put it on the end. When
; we release a mutex, we pull it off the end and put it on the front. That way the mutexes on the back will be the ones with the most
; processes waiting on them and the ones on the front will be the ones with the least. Since we don't know anything about the runtime of
; the processes acquiring the mutex, this is a decent but imperfect load-balancing scheme. Note that this works only because it doesn't 
; matter whether a process releases the same mutex that it had acquired. It only matters that the pool size doesn't change. 

; Do we need to protect the operations we perform on the deque? Yes, we do. If we processes make conflicting inserts or deletes we could
; change the size of the pool.

(define (make-semaphore n)
    (let ((mutex-deque (make-deque))
          (deque-serializer (make-serializer)))

        ; serialized deque procedures, specific to mutex-deque
        (define front-insert! (deque-serializer (mutex-deque 'front-insert-proc)))
        (define rear-insert! (deque-serializer (mutex-deque 'rear-insert-proc)))
        (define front-delete! (deque-serializer (mutex-deque 'front-delete-proc)))
        (define rear-delete! (deque-serializer (mutex-deque 'rear-delete-proc)))

        ; add n mutexes to our deque
        (for-each 
            (lambda (x) (front-insert! (make-mutex)))
            (enumerate-interval 1 n))

        (define (acquire)
            (let ((least-used-mutex (front-delete!))) 
                (rear-insert! least-used-mutex)       
                ((least-used-mutex) 'acquire))) ; acquire last, or other processes won't complete if another process alread has it
        (define (release)
            (let ((most-used-mutex (rear-delete!)))
                (most-used-mutex 'release)      ; release before insert so once a process can pull it off a list, it's ready to be pulled (no process will try to acquire it until it's added back to the queue)
                (front-insert! most-used-mutex)))
        (define (the-semaphor m)
            (cond ((eq? m 'acquire) acquire)
                  ((eq? m 'release) release)
                  (else (error "Unknown request -- make-semaphore" m))))
        the-semaphor))

; The test-and-set! version is a bit different. test-and-set will toggle the first element of a list we give it between true and false.
; False indicates that a process is not using the protected resource. True indicates that it is. If the value is false, then test-and-set!
; will change it to true (while returning false--the state it was in when called). If the value is true, then test-and-set! just returns
; true and leaves it up to the calling procedure to handle any waiting.
;
; We'll implement this with a simple list of bools. When we acquire, we'll feed each list entry to test-and-set! until we succeed. When
; we release, we'll just set the first true bool we find to false. We need to serialize the release operation so we don't have two 
; processes trying to release the same entry. But we don't need to serialize the acquire since test-and-set! is atomic and we defer
; acquisition to that procedure. And because acquiring can't interfere with release--it won't try to acquire until the release is 
; complete. (In fact, because an acquire might wait awhile, we don't want to serialize it--otherwise it would interfere with te 
; release operation it needs in order to proceed)

(define (make-semaphore n)
    (let ((proc-list 
            (map (lambda (n) false) 
                 (enumerate-interval 1 n)))
           (serializer (make-serializer)))

        ; test-and-set first entry we can, retry with next entry until we set one, 
        ; retry with entire list if we make it all the way through
        (define (acquire)
            (define (acquire-using-list l)
                (if (null? l)
                    (acquire-using-list proc-list) ; start over
                    (if (test-and-set! l)
                        (acquire-using-list (cdr l)))))
            (acquire-using-list proc-list))

        (define (release)
            (define (release-using-list l)
                (if (null? l) ; shouldn't happen => release should always have a corresponding acquire performed earlier, so should never reach end of list
                    (error "tried to release semaphore without corresponding acquire -- MAKE-SEMAPHORE" proc-list)
                    (if (car l)
                        (set-car! l false)
                        (release-using-list (cdr l))))))

        (define (the-semaphor m)
            (cond ((eq? m 'acquire) acquire)
                  ((eq? m 'release) (serialize release))
                  (else (error "Unknown request -- make-semaphore" m))))
        the-semaphor))

