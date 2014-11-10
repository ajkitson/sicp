; Explain, in general, why equivalent algebraic epxressions may lead to different answer. Can you devise an interval-arithmetic package
; that does not have this shortcoming, or is this task impossible? (Warning: this problem is very difficult.)
; =====
; Wikipedia describes this pretty nicely: http://en.wikipedia.org/wiki/Interval_arithmetic#Dependency_problem
; The gist is that, as discussed in 2.15, operating on uncertain values produces greater uncertainty and when you have the same
; value included twice, you will get more uncertainty/error, more than you have to have. Now, as with par1 and par2, some function
; can be re-written to an algebraically equivalent version that uses the input interval(s) less. However, not all functions can be
; re-written this way. So that's one limit. 
; 
; The other limit is that reducing uncertainty is done by rewriting the function. It's not a matter of designing the arithmetic 
; operations that the function uses differently. So you would need to somehow refactor the input function to only use the input intervals
; once (or detect and get rid of superfluous uses). That's beyond me. 