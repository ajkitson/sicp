; Modify the make-account procedure so tat it creates password-protected accounts. That is, make-account should take a symbol as an
; additional argument, as in:

; (define acc (make-account 100 'secret-password))

; The resulting account object should process a request only if it is accompanied by the password with which the account was created,
; and should otherwise return a complaint
; =====
; I left everything in make-account alone except the return value. Instead of returning dispatch, we return a wrapper to dispatch
; that checks the password first. This will let us use dispatch later internally if we want to. Also, created a handler for 
; bad passwords. All it does is absorb whatever parameters we passed with the incorrect password--basically, we always need
; to return a procedure, even if we don't have the correct password or we run into a scheme-level error (not one we're handling).
; bad-password-handler just returns an error message and prevents scheme from erroring out.

(define (make-account balance pw)
	(define (withdraw amount)
		(if (>= balance amount)
			(begin (set! balance (- balance amount))
				balance)
			"Insufficient funds"))
	(define (deposit amount)
		(set! balance (+ balance amount))
		balance)
	(define (dispatch m)
		(cond ((eq? m 'withdraw) withdraw)
			  ((eq? m 'deposit) deposit)
			  (else (error "Unkown request -- MAKE-ACCOUNT" m))))
	(define (bad-password-handler . args) "Incorrect password")  ; take whatever args would have been passed to the other procedures
	(lambda (password req)
		(if (eq? password pw)
			(dispatch req)
			bad-password-handler)))



1 ]=> (define acc (make-account 1000 'pass))
;Value: acc

1 ]=> ((acc 'pass 'withdraw) 200)
;Value: 800

1 ]=> ((acc 'pass 'deposit) 300)
;Value: 1100

1 ]=> ((acc 'no-good 'withdraw) 300)
;Value 88: "Incorrect password"