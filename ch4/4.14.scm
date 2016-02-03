; Eva Lu Ator and Louis Reasoner are each experimenting with the metacircular
; evaluator. eva types in the definition of map, and runs some test programs
; that use it. They work find. Louis, in contrast, has installed the system verion
; of map as a primitive for the metacircular evaluator. When he tries it, things
; go terribly wrong. Explain why Louis' map fails even though Eva's works.
; =======
; Louis' map fails because the system version of map and the map that Eva
; defined expect different types of inputs. Specifically, they expect the
; lambda or procedure used in the map to be represented in different ways.
; The system version of map expects an actual procedure or lambda, as defined
; by the system. But our evaluator will instead give it a representation like
; (list 'compound-procedure (list n) (list (list + n 1)) <environment>)
;
; The system procedure doesn't know how to interpret this and so fails. Which
; means that the only procedures that should be defined as primitive are ones
; where the arguments are represented (when fully evaluated) in the same way in
; both our evaluator and in the system version of scheme.
