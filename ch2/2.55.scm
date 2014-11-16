; Eva Lu Ator types to the interpreter the expression: (car ''abracadabra). 
; To her surprise, the interpreter prints back quote. Explain.
; =====
; Hmmm. There's part of this I'm pretty sure of and part speculation. Now, the part I'm sure of is that the single quote is 
; shorthand for a procedure named quote, and what quote does is indicate that you're referring to the symbol being quoted and 
; not the value of the symbol(s). So, while one quote alone would make it so we're referring to the symbol abracadabra, two quotes
; means we're referring to the quotation of the symbol abracadabra, or the combination of symbols: 'abracadabra, or quote abracadabra
; 
; Now, the part I'm less sure of and that is partly speculation is how car works in this context. Normally, car grabs the first
; item from a list. Since it returns quote (the procedure name for quoting), I must assume that 'abracadabra is really a list
; with two items (the symbols quote and abracadabra) and that this list implicitly created when you quote an expression. That is,
; expressions are really just lists where the first element is a procedure whose remaining elements are its arguments. And that's 
; how we can use list operations on quoted expressions--because they are just lists.