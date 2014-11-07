; In case representing pairs as procedures wasn't mind-boggling enough, consider that, in a language that can manipulate procedures,
; we can get by without numbers (at least insofar as nonnegative integers are concerned) by implementing 0 and the operation of adding
; 1 as:

; (define zero (lambda (f) (lambda (x) x)))

; (define (add-1 n)
; 	(lambda (f) (lambda (x) (f ((n f) x)))))

; This representation is known as Church's numerals, after its inventor Alonzo Church. 

; Define one and two directly (not in terms of zero and add-1). (Hint: Use substitution to evaluate (add-1 zero)). Give a direct 
; definition of the addition procedure + (not in terms of repeated application of add-1).
; ======
; Whoa. What's going on here? Let's see if we can pick it apart.
; Zero is a lambda that takes a procedure as an argument (guessing based on the argument name), doesn't do anything with it, 
; and returns a lambda that just returns it's one argument. So f was applied zero times--a clue?
;
; add-1 take a single argument. That argument, n, is used as a procedure. OK, that fits with numbers being represented as procedures.
; add-1 returns a lambda that takes a procedure f as its sole argument and returns a lambda that will take a single argument x and
; iteself return (f ((n f) x)). So we've got a number procedure that somehow modifies f. We then pass x to the modified procedure
; (which does whatever it does... we don't know yet) and then runs that value through f. I'm guessing that n is a procedure that 
; simply applies f n times. So ((n f) x) ends up being (f (f ... (f x))). That is, add-1 just applies f one more time than n does.
; 
; Starting to get a feel for it, but still not there. Let's take the hint and see if doing substitution on (add-1 zero) sheds 
; light on things:
(add-1 zero)
; expand add-1 and replace n w/expanded zero
(lambda (f) (lambda (x) (f (((lambda (g) (lambda (y) y)) f) x))))
; reduce inner lambda (which just becomes (lambda (x) x))
(lambda (f) (lambda (x) (f ((lambda (y) y) x))))
; reduce inner lambda again
(lambda (f) (lambda (x) (f x)))
; This is as far as we can reduce, and it must be our definition of one. 

(define one (lambda (f) (lambda (x) (f x))))
; This fits with our speculation above that a number corresponds to how often f is applied. I'm still unclear on when or how x
; gets a value, though. Let's define two (as per instructions) and then see if we can play around with the numbers

(add-1 one)
((lambda (n) (lambda (f) (lambda (x) (f ((n f) x))))) (lambda (g) (lambda (y) (g y))))
(lambda (f) (lambda (x) (f (((lambda (g) (lambda (y) (g y))) f) x)))) 
(lambda (f) (lambda (x) (f ((lambda (y) (f y)) x)))) 
(lambda (f) (lambda (x) (f (f x)))) 

(define two (lambda (f) (lambda (x) (f (f x)))))
; OK, so number of applications of f corresponds the church numbers. Let's try out these numbers. They each return a function
; that will apply the supplied procedure n times to input x, so we can do things like this:

1 ]=> ((two square) 4)
;Value: 256

1 ]=> ((two (lambda (n) (+ n 1))) 7)
;Value: 9

; Got it. That works. So we're applying the procedure twice. 
; I think I see how to do addition. To add numbers a and b, we just need to return a lambda that applies f a + b, and
; maintain the form of our numbers: (lambda (f) (lambda (x) <some number of applications of f to x>)). 
; Here's what I got after plenty of futzing with the nesting:

(define (plus a b)  ; modeled on add-1
	(lambda (f) (lambda (x) ((a f) ((b f) x)))))

; Let's do some substitution and see if this works out:
(plus one two)
(lambda (f) (lambda (x) (((lambda (g) (lambda (y) (g y))) f) (((lambda (h) (lambda (z) (h (h z)))) f) x))))
(lambda (f) (lambda (x) ((lambda (y) (f y)) ((lambda (z) (f (f z))) x))))
(lambda (f) (lambda (x) ((lambda (y) (f y)) (f (f x)))))
(lambda (f) (lambda (x) (f (f (f x)))))

; The tricky thing for me was fully switching to thinking of a and b as procedures that apply f a-times or b-times, not quite numbers
; themselves, which meant that I needed to pass each of them f independently. I tried for too long to do (a (b f)) and combinations 
; like that.
;
; So now let's try it out!
1 ]=> (define three (plus two one))
;Value: three

1 ]=> (define five (plus two three))
;Value: five

1 ]=> ((five (lambda (n) (+ n 1))) 0)
;Value: 5

; So in what way are these really numbers? Well, I suppose in that you can use them for a lot of the same things you would
; use numbers for, especially in coding. Things like how many times to run a block of code. But you couldn't save this to a database
; or anything like that. However, if the database understood a command like inc, you could tell it to inc n times and end up with a 
; number that way. 
;
; What had confused me earlier on though was how these are just abstraction on their own. In order to mean anything or do anything, 
; you need to supply the f and the x, and these will be concrete. 


