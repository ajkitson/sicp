; Consider the bank account objects created by make-account, with the password modification described in exercise 3.3. Suppose that our
; banking system requires the ability to make joint accounts. Define a procedure make-joint that accomplishes this. make-joint should
; take three arguments. The first is a password-protected account. The second argument must match the password with which the account
; was defined in order for the make-joint operation to proceed. The third argument is a new password. Make-joint is to create an 
; additional access to the original account using the new password. For example, if peter-acc is a bank account with te password
; open-sesame, then 
;
; (define paul-acc 
; 	(make-joint peter-acc 'open-sesame 'rosebud))
;
; will allow one to make transactions on peter-acc using the name paul-acc and the password rosebud. You may wish to modify your
; solution to exercise 3.3 to accomodate this new feature.
; ======
; The definition doesn't specify whether the passwords are specific to the each account definition. That is, should I be able to 
; access peter-acc with both rosebud or open-sesame? Or just open-sesame? 
;
; I'm going to implement it such that the password is specific to the account definition since that's closest to the real world
; username/password combo you need. Even if some other user has access to the same account, you can't get in with your username
; and their password.
;
; There are a couple ways we could implement this. The easy way is to just create a wrapper for the original account, where we 
; basically hang onto the original password and access the account through that original password, and just use the joint-account
; password to verify that we should be allowed to do this.
;
; Here's an implementation of that idea. It doesn't require any changes to make-account.

(define (make-joint account original-pw new-pw)
	(lambda (password req)
		(if (eq? password new-pw)
			(account original-pw req)
			bad-password-handler)))

; in action:
1 ]=> (define peter-acc (make-account 100 'peter-pw))
1 ]=> (define paul-acc (make-joint peter-acc 'peter-pw 'paul-pw))
1 ]=> ((peter-acc 'peter-pw 'deposit) 50)
;Value: 150
1 ]=> ((paul-acc 'paul-pw 'deposit) 30)
;Value: 180
1 ]=> ((peter-acc 'peter-pw 'withdraw) 100)
;Value: 80

; This works sort of, but it's not good. Paul would lose access to the account if Peter every changes his password (since Paul just 
; uses Paul's password, via the closure, to access the account). Also, if we wanted to track who took what actions, we couldn't 
; record those either because the account is only accessed directly under Paul's credentials. 
;
; Let's do something better. We'll update make-account to allow access with different sets of credentials. At first I thought we'd
; have to store the different passwords in a list and do a lookup, but we don't have to do any of that. We just need to make sure
; that the lambda we return has access to the account's specific password, which we can do easily enough by moving the lambda we
; had been returning directly from make-account to a separate procedure called add-account. Add-account returns a lambda that 
; checks the password before calling dispatch. Because we pass the password as an argument to add-account, the lambda has the 
; account-specific password available to check against. Simple. Then just make add-account available via dispatch so make-joint 
; can call it.

(define (make-account balance pw)
	(define (withdraw amount)
		(if (>= balance amount)
			(begin 
				(set! balance (- balance amount))
				balance)
			"Insufficient funds"))
	(define (deposit amount)
		(set! balance (+ balance amount))
		balance)
	(define (dispatch m)
		(cond ((eq? m 'withdraw) withdraw)
			  ((eq? m 'deposit) deposit)
			  ((eq? m 'add-account) add-account)
			  (else (error "Unkown request -- MAKE-ACCOUNT" m))))
	(define (bad-password-handler . args) "Incorrect password")  ; take whatever args would have been passed to the other procedures
	(define (add-account pw)
		(lambda (password req)
			(if (eq? password pw)
				(dispatch req)
				(bad-password-handler))))
	(add-account pw))

(define (make-joint primary-acc primary-pw new-pw)
	((primary-acc primary-pw 'add-account) new-pw))

; Create Paul's account and do some stuff with it -- see, it still works:
1 ]=> (define paul-acc (make-account 100 'paul-pw))
1 ]=> ((paul-acc 'paul-pw 'deposit) 20)
;Value: 120
1 ]=> ((paul-acc 'paul-pw 'deposit) 20)
;Value: 140
1 ]=> ((paul-acc 'paul-pw 'withdraw) 20)
;Value: 120

; Now add Peter to Paul's account and show we have access:
1 ]=> (define peter-acc (make-joint paul-acc 'paul-pw 'peter-pw))
1 ]=> ((peter-acc 'peter-pw 'withdraw) 10)
;Value: 110
1 ]=> ((peter-acc 'peter-pw 'deposit) 10)
;Value: 120
1 ]=> ((peter-acc 'peter-pw 'deposit) 10)
;Value: 130
1 ]=> ((peter-acc 'peter-pw 'deposit) 10)
;Value: 140
1 ]=> ((peter-acc 'peter-pw 'deposit) 10)
;Value: 150

; And back to Paul:
1 ]=> ((paul-acc 'paul-pw 'deposit) 10)
;Value: 160
