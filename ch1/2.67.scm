; Define an encoding tree and a sample message:
;
; (define sample-tree
; 	(make-code-tree 
; 		(make-leaf 'A 4)
; 		(make-code-tree
; 			(make-leaf 'B 2)
; 			(make-code-tree (make-leaf 'D 1) (make-leaf 'C 1)))))

; (define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))

; Use the decode procedure to decode the message.
; ====
; We'll do two things. First we'll decode without the code procedure, and then we'll use the decode procedre to check.
;
; Here's the tree the above should generate
;	 .
;	/ \
;  A   .
;	  / \
; 	 B   .
; 		/ \
; 	   D   C
;
; Which means our message should be ADABBCA
;
; Now let's test it. The decode procedure and supporting code is below. Here it is in action:
1 ]=> (decode sample-message sample-tree)
;Value 4: (a d a b b c a)


(define (decode bits tree)
	(define (decode-1 bits current-branch)
		(if (null? bits)
			'()
			(let 
				((next-branch 
					(choose-branch (car bits) current-branch)))
				(if (leaf? next-branch)
					(cons (symbol-leaf next-branch)
						(decode-1 (cdr bits) tree))
					(decode-1 (cdr bits) next-branch)))))
	(decode-1 bits tree))

(define (choose-branch bit branch)
	(cond ((= bit 0) (left-branch branch))
		((= bit 1) (right-branch branch))
		(else (error "bad bit! -- CHOOSE-BRANCH" bit))))

(define (leaf? object) 
	(eq? (car object) 'leaf))
(define (symbol-leaf leaf)
	(cadr leaf))
(define (left-branch tree) (car tree))
(define (right-branch tree) (cadr tree))

(define (make-leaf symbol weight)
	(list 'leaf symbol weight))
(define (symbol-leaf leaf)
	(cadr leaf))
(define (weight-leaf leaf)
	(caddr leaf))
(define (make-code-tree left right)
	(list left
		right
		(append (symbols left) (symbols right))
		(+ (weight left) (weight right))))
(define (symbols tree)
	(if (leaf? tree)
		(list (symbol-leaf tree))
		(caddr tree)))
(define (weight tree)
	(if (leaf? tree)
		(weight-leaf tree)
		(cadddr tree)))
