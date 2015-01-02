; Suppose we evaluate the following sequence of expressions in the global environment:
;
; (define a (make-connector))
; (define b (make-connector))
; (set-value! a 10 'user)
;
; At some time during evaluation  of the set-value!, the following expression from the connector's local procedure is evaluated:
; (for-each-except setter inform-about-value constraints)
;
; Draw an environment diagram showing the environment in which the above expression is evaluated.
; =========
; We start with definitions for a and b in the global environment. When we define each of these, we create an environment that contains
; the local state set up in make-connector. The code for a and b (the me procedure) is associated with each envonrment:

global
 __________________
| a: --------------|----> @ --------------------------,--> parameters: request
|                  |      @---,                       |          body: (cond ((eq? resuest ...)))
|                  |          |                       |
|                  |       ___|_________________      |
|                  |   E1 | value: false        |     |
|                  |<-----| informant: false    |     |
|                  |      | constraints: '()    |     |
|                  |      |_____________________|     |
|                  |                                  |
|                  |                                  |
| b: --------------|----->@ --------------------------'
|                  |      @---,
|                  |          |
|                  |       ___|_________________
|                  |   E2 | value: false        |
|                  |<-----| informant: false    |
|                  |      | constraints: '()    |
|                  |      |_____________________|
|__________________|

; Then, when we evauate (set-value! a 10 'user), the following happens:
; - we create an env off the global for set-value!, where set-value! is defined.
; - this passes the 'set-value! message to a, and we create an environment off E1 where request: 'set-value!
; - we then create an environment also off E1 for the actual set-my-value! call (the local one)
; - it's in here that we hit the for-each-except call. By the time we get there, we've set value and informant, and there
;   are still no constraints (because we haven't built any constraints with our connector).
;
; Here's what all that looks like (dropping the definition of b to make space);

global
 __________________
| a: --------------|----> @ --------------------------,--> parameters: request
|                  |      @---,                       |          body: (cond ((eq? resuest ...)))
|                  |          |                       |
|                  |       ___|_________________      |     _______________________
|                  |   E1 | value: 10           |     | E4 | request: 'set-value!  | (a 'set-value!)
|                  |<-----| informant: 'user    |<----|----|_______________________|
|                  |      | constraints: '()    |     |     ________________
|                  |      |_____________________|<----|----| newval: 10     | (set-my-value 10 'user)
|                  |                                  | E5 | setter: 'user  |  <-----THIS IS WHERE WE CALL FOR-EACH-EXCEPT
|                  |                                  |    |________________|
| b: --------------|----->@ --------------------------'
|                  |      @---,
|                  |          |
|                  |       ___|_________________
|                  |   E2 | value: false        |
|                  |<-----| informant: false    |
|                  |      | constraints: '()    |
|                  |      |_____________________|
|                  |       _______________
|                  |   E3 | connector: a  | (set-value!)
|                  |<-----|_______________|
|                  |    
|                  |    
|__________________|

