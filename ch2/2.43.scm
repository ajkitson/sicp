; Louis Reasoner is having a terrible time doing exercise 2.42. His queens procedure seems to work but it runs extremely slowly. (Louis
; never does manage to wait long enough for it to solve even the 6 x 6 case.) When Louis asks Eva Lu Ator for help, she points out
; that he has interchanged the order of the nexted mappings in the flatmap, writing it as:

; (flatmap 
; 	(lambda (new-row)
; 		(map 
; 			(lambda (rest-of-queens)
; 				(adjoin-position new-row k rest-of-queens)
; 				(queen-cols (- k 1)))))
; 	(enumerate-interval 1 board-size))

; Explain why this interchange makes the program run slowly. Estimate how long it will take Louis' program to solve the eight queens
; puzzle, assuming that the program is exercise 2.42 solves the puzzle in time T.
; ====
; With this change, Louis put the call to queen-cols in the inner loop, meaning that it gets called MUCH more. How much more? Well,
; in the correct version, we call queen-cols once per column. That is, for a board of size n, we basically end up doing:
; (queen-cols n) -> (queen-cols n-1) ... (queen-cols 0). So we call queen-cols n + 1 times (+ 1 b/c we include 0). 
; Louis' version, however, calls queen-cols for each new row we add to a column. So for getting positions on the first column,
; we call (queen-cols 0) for each row (or board-size times). When we get positions for the second column, we call (queen-cols 1)
; for each row, and each of these calls (queen-cols 0) for each row. So now we have board-size squared number of calls to queen-cols,
; just doing the second row. Our number of calls to queen-cols is board-size^board-size. Yikes!
; 
; This means that if, for a given board-size, we take time T in the correct version (for all queen-cols calls, or board-size  number
; of queen-cols calls), Luois' version will take time T^board-size. 
