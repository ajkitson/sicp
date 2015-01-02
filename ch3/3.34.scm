; Louis Reasoner wants to build a squarer, a constraint device with two terminals such that the value of connector b on the second terminal
; will always be the square of the value a on the first terminal. He proposes the following simple device made from a multiplier:
;
; (define (square a b)
;     (multiplier a a b))
;
; There is a serious flaw in this idea. Explain.
; ========
; The flaw is that square will only work one way--it will compute b from a, but not a from b. This is that two of the three values need
; to be defined in order to compute the remaining value. If a is defined, then we get two inputs on the multiplier and can calculate
; b. But if have b defined and not a, we'll never get a because we only have one of three inputs to multiplier defined. 