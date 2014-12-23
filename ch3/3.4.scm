; Modify the make-account procedure of exercise 3.3 by adding another local state variable so that, if an account is accessed more than 
; seven consecutive times with an incorrect passord, it invoces the procedure call-the-cops.

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
	(define (call-the-cops . args) "Hello, 911? We have an emergency.")
	(let ((incorrect-cnt 0))
		(lambda (password req)
			(if (eq? password pw)
				(begin 
					(set! incorrect-cnt 0)
					(dispatch req))
				(begin
					(set! incorrect-cnt (+ incorrect-cnt 1))
					(if (> incorrect-cnt 7) call-the-cops bad-password-handler))))))


; It works if you have the correct password:
1 ]=> ((acc 'pass 'withdraw) 200)
;Value: 800
1 ]=> ((acc 'pass 'deposit) 400)
;Value: 1200

; But not if the password is wrong:
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"

; And then if we've had 7 incorrect in a row we call the cops:
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 91: "Hello, 911? We have an emergency."
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 91: "Hello, 911? We have an emergency."

; But that's reset once we log in with the correct password again
1 ]=> ((acc 'pass 'deposit) 400)
;Value: 1600
1 ]=> ((acc 'wrong 'withdraw) 200)
;Value 90: "Incorrect password"