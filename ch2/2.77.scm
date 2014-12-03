; Louis Reasoner tries to evaluate the expression (magnitude z) where z is the object shown in figure 2.24. To his surprise, instead of the 
; answer 5 he gets an error message from apply-generic, saying there is no method for the operation magnitude on the types (complex).
; He shows this interaction to Alyssa P. Hacker, who says "The problem is that the complex-number selectors were never defined for 
; complex numbers, just for polar and rectangular numbers. All you have to do to make this work is add the following to the complex
; package:"

; (put 'real-part '(complex) real-part)
; (put 'imag-part '(complex) imag-part)
; (put 'magnitude '(complex) magnitude)
; (put 'angle '(complex) angle)

; Describe in detail why this works. As an example, trace through all the procedures called in evaluating the expression (magnitude z)
; where z is the object shown in figure 2.24. In particular, how many times is apply-generic invoked? What procedure is dispatched to
; in each case?
; ======
; Let's start with how magnitude is defined (section 2.4.3, pg 184): 
; (define (magnitude z) (apply-generic 'magnitude z))
; And let's be clear on how z is defined. The object in 2.24 is a complex number represented as '(complex rectangular 3 4).
;
; So when Louis called (magnitude z), apply-generic tried to find a procedure for the operation magnitude on the complex type.
; There was none because none had been added to the table.
; 
; If we follow Alyssa's suggestion, it works. Here's how:
; 1. We invoke (magnitude z)
; 2. This calls (apply-generic 'magnitude z). This looks for a procedure for the operation 'magnitude and the type 'complex (from 
;	 how z was tagged). It finds one because we just added it to the table
; 3. This calls (magnitude z'), where z' is z stripped of the 'complex tag.
; 4. Now we're back at apply-generic, but with a different z: (apply-generic 'magnitude z') Because z' doesn't have the complex tag
;	 anymore, apply-generic processes it as a 'rectangular complex number and looks for and finds a magnitude procedure for 
;	 recgangular representations of complex numbers.
;
; Basically, we needed to add the selectors to the complex time in order to strip off the complex number type and redirect to the 
; appropriate selector for the type of complex number.
>>