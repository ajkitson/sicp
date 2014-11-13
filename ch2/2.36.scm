; The procedure accumulate-n is similar to accumulate except that it takes as it third argument a sequence of sequences, which are all
; assumed to have the same number of elements. It applies the designated accumulation procedure to combine all the first elements of 
; the sequences, all the second elements of the sequences, and so on, and returns a sequence of the results. For instance, if s is a
; sequence containing four sequences, ((1 2 3) (4 5 6) (7 8 9) (10 11 12)), then the value of (accumulate-n + 0 s) should be the 
; sequence (22 26 30). Fill in the missing expressions in the following definition of accumulate n:
;
; (define (accumulate-n op init seqs)
; 	(if (null? (car seqs))
; 		(list)
; 		(cons 
; 			(accumulate op init ??)
; 			(accumulate-n op init ??))))
; ======
; We just want to pluck the first value from each sub-sequence, so we map car over the top-level seq, and then cons that 
; with the accumulate-n for the rest of the values in each subseq, so we call accumulate-n recursively and map cdr over the 
; top level seq to get the sub-seqs without their first value.

(define (accumulate-n op init seqs)
	(if (null? (car seqs))
		(list)
		(cons 
			(accumulate op init (map car seqs))
			(accumulate-n op init (map cdr seqs)))))