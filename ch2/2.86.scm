; Suppose we want to handle complex numbers whose real parts, imaginary parts, magnitudes, and angles can be either ordinary numbers,
; rational numbers, or other numbers we might wish to add to the system. Describe and implement the changes to the system needed
; to accomodate this. You will have to define operations such as sine and cosine that are generic over ordinary numbers and
; rational numbers.
; =====
; This is mostly a matter of replacing the scheme arithmetic operators with our generic ones. The trick is in how thorough-going
; we need to be. At first I thought that we could just update the complex package and that'd be enough. It is for add and sub when
; using a rectangular represenation and the rational number is really just an integer represented as a rational:

1 ]=> (add (make-complex-from-real-imag 6 0) (make-complex-from-real-imag (make-rational 10 2) 3))
;Value 40: (complex rectangular 11 . 3)

1 ]=> (sub (make-complex-from-real-imag 6 0) (make-complex-from-real-imag (make-rational 10 2) 3))
;Value 41: (complex rectangular 1 . -3)

; Or if we multiply and divide using the polar representation:
1 ]=> (div (make-complex-from-mag-ang 6 0) (make-complex-from-mag-ang (make-rational 10 2) 3))
;Value 44: (complex polar 6/5 . -3)

1 ]=> (mul (make-complex-from-mag-ang 6 0) (make-complex-from-mag-ang (make-rational 10 2) 3))
;Value 45: (complex polar 30 . 3)

; Anything else results in an error when we convert between representations. OK, I should have expected that. That's why they told
; me I'd have to implement sine and cosine, etc. Still, it's good to see that, once we get the representation right, it works as 
; expected	
;
; Let's implement those other procedures. Which do we need? These are the operations we haven't yet defined generically that are used
; to convert between the different representations of complex numbers: sqrt, atan, cos, sin. For scheme numbers, we can just
; use the built-ins. 
; 
; The trig functions on rational numbers poses a problem because we might get a result that can't be expressed as a rational number.
; Not just might: almost certainly will. So, how do express the result? We could try to hang onto the rational number representation 
; and make the sin of a rational number the sin(numer)/sin(denom), but this seems wrong. Why hold onto the rational number if the 
; parts aren't integers? So for now, we'll not stick to returning rational numbers for these. Same for sqrt. So really, the rational 
; number procedures will mostly just pass (/ (numer n) (denom n)) to the standard functions.
;
; Here's the updated parts of the scheme-number and rational packages. I got sick of writing the (lambda...) for deferring to the
; package's internal funcitn so wrote a wrapper for the rational package

;; Scheme-Number
(define (install-scheme-number-package)
  ;; ... other arithmetic operators ...

  ; simply defer to built-ins
  (put 'sqrt '(scheme-number) sqrt)
  (put 'sin '(scheme-number) sin)
  (put 'cos '(scheme-number) cos)
  (put 'atan '(scheme-number scheme-number) atan)

  ; .... other stuff
  'done)

;; Rational Number
(define (install-rational-package)
  ; .... other arith ops

  (define (to-real n) ; convert to a real number
    (/ (numer n) (denom n)))

  (define (real-fn f) ; wrapper to pass rational n to given fn as a real num
    (lambda (n) (f (to-real n))))

  (put 'sqrt '(rational) (real-fn sqrt))
  (put 'sin '(rational) (real-fn sin))
  (put 'cos '(rational) (real-fn cos))
  (put 'atan '(rational rational) 
  	(lambda (n m) (atan (to-real n) (to-real m))))

  ; .... ohter stuff
  'done)


; Then we define the general functions:
(define (sin-gen n) (apply-generic 'sin n))
(define (cos-gen n) (apply-generic 'cos n))
(define (atan-gen n m) (apply-generic 'atan n m)) ; forgot this takes two args the first time
(define (sqrt-gen n) (apply-generic 'sqrt n))

; When I first tried it from here, I was getting this error:
; 3 error> (add n m)
;The object .8414709848078965, passed as an argument to gcd, is not an integer.

; This uncovered an issue with the coercion from scheme-number->rational in that it assumed the scheme number was an int... which
; we want it to be in making a rational number. But it wasn't always true. For now, I'm just rounding the scheme-number in the
; coercion. Could get fancier here and if the number is a rational decimal try to convert to a fraction, but that's for another day.

; Corrected this and finally it works!

; We'll see what we get first with a complex number defined with ints:
1 ]=> (define a (make-complex-from-real-imag 5 2))
1 ]=> (add a a)
;Value 98: (complex rectangular 10 . 4)
1 ]=> (sub a a)
;Value: 0
1 ]=> (mul a a)
;Value 99: (complex polar 28.999999999999996 . .7610127542247298)
1 ]=> (div a a)
;Value: 1.

; And just to make sure everything works a * a / a + a - a = a
1 ]=> (sub (add a (div (mul a a) a)) a)  
;Value 102: (complex rectangular 5. . 2.)

; OK, now here are the same manipulations but with the real and imaginary parts defined as rational numbers:
1 ]=> (define a (make-complex-from-real-imag (make-rational 15 3) (make-rational 4 2)))

; Here's a to show that we don't convert to scheme-nums on creating the complex number:
1 ]=> a
;Value 106: (complex rectangular (rational 5 1) rational 2 1)


1 ]=> (add a a)
;Value 103: (complex rectangular 10 . 4)
1 ]=> (sub a a)
;Value: 0
1 ]=> (mul a a)
;Value 104: (complex polar 28.999999999999996 . .7610127542247298)
1 ]=> (div a a)
;Value: 1.
1 ]=> (sub (add a (div (mul a a) a)) a)
;Value 105: (complex rectangular 5. . 2.)


; So for real/image representation we get the same values whehter we use reational or scheme numbers to build it
; Now let's confirm the mag/ang representation, first with ints:

1 ]=> (define b (make-complex-from-mag-ang 5 2))
1 ]=> (add b b)
;Value 108: (complex rectangular -4.161468365471424 . 9.092974268256818)
1 ]=> (sub b b)
;Value: 0.
1 ]=> (mul b b)
;Value 109: (complex polar 25 . 4)
1 ]=> (div b b)
;Value: 1
1 ]=> (div (mul (sub (add b b) b) b) b)
;Value 114: (complex polar 5. . 2.)

; Now with rationals in place of the ints (equivalent value, though). Some of these are not the exact value because we lose precistion
; each time we convert between scheme nums and rational nums.
1 ]=> (add b b)
;Value 159: (complex rectangular -4.161 . 9.093)
1 ]=> (sub b b)
;Value: 0.
1 ]=> (mul b b)
;Value 160: (complex polar 25 . 4)
1 ]=> (div b b)
;Value: 1
1 ]=> (div (mul (sub (add b b) b) b) b)
;Value 161: (complex polar 4.999914249264681 . 1.9999563400810616)

