(define (every test elements)
	(cond
		((null? elements) true)
		((test (car elements)) (every test (cdr elements)))
		(else false)))

(define (some test elements)
	(cond 
		((null? elements) false)
		((test (car elements)) (car elements))
		(else (some test (cdr elements)))))

(define (subsets s)
	(if (null? s)
		(list (list)) ; empty list... just (list) is ignored
		(let ((rest (subsets (cdr s))))
			(append 
				rest 
				(map (lambda (x) (cons (car s) x)) rest)))))

(define (fringe tree)
	(if (null? tree)
		(list)
		(let ((item (car tree)))
			(append
				(if (not (pair? item)) (list item) (fringe item))
				(fringe (cdr tree))))))

(define (tree-map fn tree)
	(map (lambda (x)
			(if (not (pair? x))
				(fn x)
				(tree-map fn x)))
		tree))

(define (accumulate op initial sequence)
	(if (null? sequence)
		initial
		(op (car sequence) 
			(accumulate op initial (cdr sequence)))))

(define (accumulate-n op init seqs)
	(if (null? (car seqs))
		(list)
		(cons 
			(accumulate op init (map car seqs))
			(accumulate-n op init (map cdr seqs)))))

(define (flatmap f seq)
	(accumulate append '() (map f seq)))

(define (enumerate-interval start end)
	(if (> start end)
		(list)
		(cons start (enumerate-interval (+ start 1) end))))

(define (unique-pairs n)
	(flatmap 
		(lambda (i) 
			(map (lambda (j) (list i j)) (enumerate-interval 1 (- i 1))))
		(enumerate-interval 1 n)))
