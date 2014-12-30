; Redo exercise 3.18 using an algorithm that takes only a constant amount of space. (This requires a very clever idea.)
; ====
; I'm well aware that the solution to 3.18 requires O(n^2) time, since for each element we check all the following elements in the list.
; But how much *space* do we require? Looks to me like it's already constant space since we're not saving anything off, creating new lists,
; etc. We're just comparing each element to the following elements (for the top-level list and recursively on any nested lists), which
; means we're not creating any new structures. And yet the "very clever idea" throws me. Either 3.18 was clever of me or I'm missing
; something re: the constant space requirement. More likely the later.
;
; ... Did some research and found the clever idea! It's the tortoise and hare algorithm--pretty cool. The space is the same as what
; we were doing, but the time is much, much better.
;
; The general idea is that, instead of comparing each element to all the following elements to see if there's a cycle, we only need
; to compare each element (the tortoise) to an element twice as far down the list (the hare). If there is a cycle, then at some
; point the tortoise and the hare will be the same element. That happens once the index of the tortoise is a multiple of the cycle
; length. The nature of a cycle is that any element in the cycle is equal to the element X indices further down, where X is the cycle
; length. Moreover, the elements at all the indices that are some integer multiple of the cycle length further down the list are the 
; same. So once the tortoise hits an index that's the multiple of the cycle length, we know that the hare, twice as far down the list
; is sitting on the same value. 
;
; From this, we can deduce a lot (like what the cycle length is, start of the cycle, etc). But we just want to know whether there's a 
; cycle at all. So, we just need to look for the point where the tortoise's value = the hare's value. And if the hare reaches the end
; of the list, then we know we don't have a cycle.
;
; How to represent this? We have our list and we'll move the toirtoise and hare as pointers down the list. In fact, since we're not 
; exactly comparing elements of the list but the list structure itself, we can just have the tortoise maintain the remaining part of 
; the list we need to check and not track that separately. 
;
; Enough talk, let's try this out:
(define (contains-cycle? x)
    (define (tortoise-and-hare tortoise hare)  
        (cond 
            ((null? hare) false)  ; check cdr so cddr hare doesn't error out
            ((eq? tortoise hare) true)       
            (else (tortoise-and-hare (cdr tortoise) (cddr hare))))) ; tortiose takes one step, hare takes two
    (tortoise-and-hare x (cdr x))) 

; It works!
1 ]=> (contains-cycle? (list 1 2 3))
;Value: #f
1 ]=> (contains-cycle? (make-cycle (list 1 2 3)))
;Value: #t

; Not an actual cycle:
1 ]=> (contains-cycle? (list 1 1 1))
;Value: #f




