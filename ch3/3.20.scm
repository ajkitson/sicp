; Draw environment diagrams to illustrate the evaluation of the sequence of expressions

; (define x (cons 1 2))
; (define z (cons x x))
; (set-car! z (cdr z) 17)

; (car x)
; 17

; Using the procedural implementation of pairs given above. (Compare exercise 3.11).
; ======
; This is trickier than I thought at first. The way that the procedural version of cons works, we set up different environments for 
; x and z, then when we call set-car! and cdr later, we start in the global environment but end up building off the x and z env.s
; with how dispatch works
;
; As context, here's the procedural definition of cons:

(define (cons x y)
    (define (set-x! v) (set! x v))
    (define (set-y! v) (set! y v))
    (define (dispatch m)
        (cond ((eq? m 'car) x)
              ((eq? m 'cdr) y)
              ((eq? m 'set-car!) set-x!)
              ((eq? m 'set-cdr!) set-y!)
              (else (error "Undefined operation -- CONS" m)))))

; OK, now let's build up this diagram. First, we start by defining x, which creates an environment off the global env where x, y, and
; dispatch are defined. x in the global env is set to the code that dispatch points to
,_________,
| x: -----|----> @-------> parameters: m
|_________|      @   ^           body: (cond ((eq? m ...)))  ; body of dispatch
       ^         |   |
 ______|____     |   |
| x: 1      |<---|   |
| y: 2      |        |
| dispatch:-|--------'
|___________|
   

; When we define z, we create another environment off the global env, just like with x, but instead of definign x and y in this
; env to be numbers, we have references back to x in the global env 
     ________
E2  | x: @   |
    | y: @   |<-----|
    |    |   |      |
    |____|___|      |
 .-------|          |
 |  ,_________,     @
 |  | z: -----|---->@ ----------|
 |  |         |                 |
 |--|>x: -----|----> @-------> parameters: m
    |         |      @   ^           body: (cond ((eq? m ...)))  ; body of dispatch
    |_________|      |   |
           ^         |   |
     ______|____     |   |
E1  | x: 1      |<---|   |
    | y: 2      |        |
    | dispatch:-|--------'
    |___________|

; Then when we evaluate (set-car! (cdr z) 17) we have a chain of evaluations. First, we look up cdr 17. cdr is defined in the global
; env, so we create an env off the global one. This routes it through the dispatch procedure in the closure in E2, so we then 
; create an env off E2 to get the cdr of z. Set-car! has a similar route, with an env created off the global one to evaluate set-car!
; which routes it through dispatch, in this case off of E1 since we're setting the car of x (Actually, two more envs off E1, one for
; (dispatch 'set-car!) and another for (set-x 17). This finally changes the value of x in that closure. Which is why, when we get 
; (car x), it is 17.
;
; Here's all that in the diagram, rearranged a bit

     ________                  __________
E2  | x: @   | (cons x x)  E4 | m: 'cdr  |  (dispatch 'cdr)
    | y: @   | <--------------|__________|
    |    |   |      
    |____|___|<-----|
 .-------| |        |
 |  ,______|__,     @
 |  | z: -----|---->@ ----------|
 |  |         |                 |
 |--|>x: -----|----> @-------> parameters: m
    |         |      @               body: (cond ((eq? m ...)))  ; body of dispatch
    |         |      |                 ^
    |         |    __|_E1_______       |
    |         |<--| x: 1 -> 17  |      |        
    |         |   | y: 2        |      |
    |         |   | dispatch ---|------|
    |         |   |_____________| (cons 1 2)    __E6__________ (dispatch 'set-car!)   
    |         |          ^   ^                 | m: 'set-car! | 
    |         |          |   |-----------------|______________|   ___E7___ (set-x! 17)
    |         |          |_______________________________________| v: 17  |
    |         |    ____E3_______________                         |________|
    |         |<--| z: @ to z in global | (cdr z)
    |         |   |_____________________|
    |         |
    |         |    ____E5_______________
    |         |<--| z: @ to x in global | (set-car! x)
    |         |   |_____________________|
    |_________|



   

