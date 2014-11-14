; The "eight queens" puzzle asks how to place eight queens on a chessboard so that no queen is in check from any other. One possible
; solution is shown. One way to solve the puzzle is to work across the board, placing a queen in each column. Once we have placed
; k - 1 queens, we must place the kth queen in a position where it does not check any of the queens already on the board. We can
; formulate this approach recursively: Assume that we have already generated the sequence of all possible ways to place k - 1 queens
; in the first k - 1 columns of the board. For each of these ways, generate an extended set of position by placing a queen in each
; row of the kth column. Now filter these, keeping only the positions for which the queen in the kth column is safe with respoect to
; the other queens. This produces the sequence of all the ways to place k queens in the first k columns. By continuing this process, 
; we will produce not only one solution, but all solutions to the puzzle. 
;
; We implement this solution as a procedure queens, which returns a sequence of all solutions to the problem of placing n queens on 
; an n x n chessboard. Queens has an internal procedure queen-cols that returns the sequence of all ways to place queens in the first
; k columns of the board.
;
; (define (queens board-size)
; 	(define (queen-cols k)
; 		(if (= k 0)
; 			(list empty-board)
; 			(filter 
; 				(lambda (positions) (safe? k positions))
; 				(flatmap   
; 					(lambda (rest-of-queens)
; 						(map 
; 							(lambda (new-row)
; 								(adjoin-position new-row k rest-of-queens)) 
; 							(enumerate-interval 1 board-size))) 
; 					(queen-cols (- k 1))))))
; 	(queen-cols board-size))
;
; In this procedure rest-of-queens is a way to place k - 1 queens in the first k - 1 columns, and new-row is a proposed row in which
; to place the queen in the kth column. Complete the program by implementing representation for sets of board positions, including the 
; procedure adjoin-position, which adjoins a new row-column position to a set of positions, and empty-board, which represents an 
; empty set of positions. You must also write the procedure safe?, which determines for a set of positions, whehter the queen in the
; kth column is safe with respect to the others. (Note that we need only check whether the new queen is safe--the other queens are 
; already guaranteed safe with respect to each other.)
; ===========
; The key challenge here is coming up with a way to represent the board, queens, and positions of queens on the board in a way that
; works for safe?, empty-board, and adjoin-position (awful name), or rather, to come up with selectors that are abstacted so that 
; these procedures don't have to care how the board, queens, and positions are implemented. 
;
; Safe? ended up needing ways to look up the row and column for a queen and remove a queen from the board.
; Adjoin-position would be better called add-queen-to-board. It didn't need anything special. I probably could have created a 
; make-position and add-position abstraction, but it edned up being so simple that I didn't bother
; empty-board I decided to implement as an empty list. Nothing special here either;
; 
; I ended up representing queen positions as (row, column) lists and the board as a list of these positions. At first, I was tempted 
; to do something simpler like represent a board as a list of integers representing queen positions, with the list index being 
; the column for the queen and the integer at the index being the row. But this was harder to reason about (especially since the 
; list is zero-indexed and the columns are not) and since I needed seectors for row and col anyway it was just as easy to use
; the less-clever but more-clear and less fragile representation of list of row/col lists. It was also easier to draw to verify 
; the answers

1 ]=> (queens 4)
;Value 32: (((3 4) (1 3) (4 2) (2 1)) ((2 4) (4 3) (1 2) (3 1)))

1 ]=> 
(display-boards (queens 4))
    Q
Q
      Q
  Q

--------
  Q
      Q
Q
    Q

--------

; Output for (queens 8) at bottom of file

; Here's the code:
(define (queens board-size)
	(define (queen-cols k)
		(if (= k 0)
			(list empty-board)
			(filter 
				(lambda (positions) (safe? k positions)) ; filter one set of positions at a time (one board setup)
				(flatmap   ; generate all combos of (1) placements of rest of queens and (2) rows in col k
					(lambda (rest-of-queens)
						(map ; for given placements of rest of the queens, create configurations with new queen at each rown in col k
							(lambda (new-row)
								(adjoin-position new-row k rest-of-queens)) 
							(enumerate-interval 1 board-size))) ; get all rows
					(queen-cols (- k 1))))))
	(queen-cols board-size))

; Safe if queen in col k (1) does not share a row with any other queen, and (2) does not share a diagonal. We assume that the 
; column is not shared since we place only one queen per column
(define (safe? k positions)
	(define (share-row q1 q2)
		(= (row q1) (row q2)))
	(define (share-diagonal q1 q2)  ; diag iff diff in rows = diff in cols
		(= (abs (- (row q1) (row q2))) 
			(abs (- (col q1) (col q2)))))
	(let ((queen-k (queen-for-col k positions)))
		(null? (filter 
				(lambda (other-queen) 
					(or (share-row queen-k other-queen)
						(share-diagonal queen-k other-queen)))
				(remove-queen queen-k positions))))) ; don't check queen-k against itself

; Just do empty list to represent an empty board
(define empty-board '())

; Add new queen at row and col, board is just list of row, col pairs that represent queen positions.
(define (adjoin-position row col board)
	(cons (list row col) board))

; Here are the selectors and other helper procedures:
(define (row queen)
	(car queen))
(define (col queen)
	(cadr queen))
(define (queen-lookup selector val board)
	(car (filter (lambda (q) (= (selector q) val)) board)))
(define (queen-for-row r board)
	(queen-lookup row r board))
(define (queen-for-col c board)
	(queen-lookup col c board))
(define (remove-queen q board)
	(filter ; use filter instead of list-ref since we're not relying on order of board
		(lambda (other-q) 
			(not (and (= (row q) (row other-q))
					(= (col q) (col other-q)))))
		board))

; and here's a little procedure to display the board (assumes there's one piece per row)
(define (display-board board)
	(define (print-n-spaces-over n val)
		(for-each
			(lambda (c) (display "  ")) ; two spaces look better than one
			(enumerate-interval 1 n))
		(display val))
	(for-each 
		(lambda (row)
			(print-n-spaces-over (- (col (queen-for-row row board)) 1) "Q")
			(newline))
		(enumerate-interval 1 (length board))))

(define (display-boards boards)
	(for-each 
		(lambda (b)
			(display-board b)
			(display " ---------------- ")
			(newline))
		boards))

1 ]=> 
(display-boards (queens 8))
Q
            Q
        Q
              Q
  Q
      Q
          Q
    Q
 ---------------- 
Q
            Q
      Q
          Q
              Q
  Q
        Q
    Q
 ---------------- 
Q
          Q
              Q
    Q
            Q
      Q
  Q
        Q
 ---------------- 
Q
        Q
              Q
          Q
    Q
            Q
  Q
      Q
 ---------------- 
          Q
Q
        Q
  Q
              Q
    Q
            Q
      Q
 ---------------- 
      Q
Q
        Q
              Q
  Q
            Q
    Q
          Q
 ---------------- 
        Q
Q
              Q
      Q
  Q
            Q
    Q
          Q
 ---------------- 
    Q
Q
            Q
        Q
              Q
  Q
      Q
          Q
 ---------------- 
        Q
Q
      Q
          Q
              Q
  Q
            Q
    Q
 ---------------- 
            Q
Q
    Q
              Q
          Q
      Q
  Q
        Q
 ---------------- 
        Q
Q
              Q
          Q
    Q
            Q
  Q
      Q
 ---------------- 
      Q
Q
        Q
              Q
          Q
    Q
            Q
  Q
 ---------------- 
  Q
          Q
Q
            Q
      Q
              Q
    Q
        Q
 ---------------- 
        Q
    Q
Q
            Q
  Q
              Q
          Q
      Q
 ---------------- 
              Q
    Q
Q
          Q
  Q
        Q
            Q
      Q
 ---------------- 
      Q
          Q
Q
        Q
  Q
              Q
    Q
            Q
 ---------------- 
        Q
            Q
Q
      Q
  Q
              Q
          Q
    Q
 ---------------- 
          Q
    Q
Q
              Q
      Q
  Q
            Q
        Q
 ---------------- 
        Q
    Q
Q
          Q
              Q
  Q
      Q
            Q
 ---------------- 
          Q
    Q
Q
              Q
        Q
  Q
      Q
            Q
 ---------------- 
      Q
              Q
Q
    Q
          Q
  Q
            Q
        Q
 ---------------- 
              Q
      Q
Q
    Q
          Q
  Q
            Q
        Q
 ---------------- 
      Q
              Q
Q
        Q
            Q
  Q
          Q
    Q
 ---------------- 
      Q
            Q
Q
              Q
        Q
  Q
          Q
    Q
 ---------------- 
          Q
      Q
Q
        Q
              Q
  Q
            Q
    Q
 ---------------- 
          Q
    Q
Q
            Q
        Q
              Q
  Q
      Q
 ---------------- 
            Q
    Q
Q
          Q
              Q
        Q
  Q
      Q
 ---------------- 
        Q
            Q
Q
    Q
              Q
          Q
      Q
  Q
 ---------------- 
  Q
        Q
            Q
Q
    Q
              Q
          Q
      Q
 ---------------- 
  Q
              Q
          Q
Q
    Q
        Q
            Q
      Q
 ---------------- 
          Q
  Q
            Q
Q
    Q
        Q
              Q
      Q
 ---------------- 
            Q
  Q
      Q
Q
              Q
        Q
    Q
          Q
 ---------------- 
              Q
  Q
      Q
Q
            Q
        Q
    Q
          Q
 ---------------- 
        Q
  Q
              Q
Q
      Q
            Q
    Q
          Q
 ---------------- 
          Q
  Q
            Q
Q
      Q
              Q
        Q
    Q
 ---------------- 
        Q
  Q
          Q
Q
            Q
      Q
              Q
    Q
 ---------------- 
    Q
        Q
            Q
Q
      Q
  Q
              Q
          Q
 ---------------- 
          Q
      Q
            Q
Q
              Q
  Q
        Q
    Q
 ---------------- 
        Q
              Q
      Q
Q
            Q
  Q
          Q
    Q
 ---------------- 
    Q
          Q
              Q
Q
        Q
            Q
  Q
      Q
 ---------------- 
            Q
        Q
    Q
Q
          Q
              Q
  Q
      Q
 ---------------- 
          Q
      Q
            Q
Q
    Q
        Q
  Q
              Q
 ---------------- 
        Q
              Q
      Q
Q
    Q
          Q
  Q
            Q
 ---------------- 
    Q
          Q
      Q
Q
              Q
        Q
            Q
  Q
 ---------------- 
    Q
          Q
              Q
Q
      Q
            Q
        Q
  Q
 ---------------- 
        Q
            Q
      Q
Q
    Q
              Q
          Q
  Q
 ---------------- 
  Q
          Q
              Q
    Q
Q
      Q
            Q
        Q
 ---------------- 
  Q
        Q
            Q
      Q
Q
              Q
          Q
    Q
 ---------------- 
  Q
            Q
        Q
              Q
Q
      Q
          Q
    Q
 ---------------- 
            Q
  Q
          Q
    Q
Q
      Q
              Q
        Q
 ---------------- 
              Q
  Q
        Q
    Q
Q
            Q
      Q
          Q
 ---------------- 
      Q
  Q
              Q
          Q
Q
    Q
        Q
            Q
 ---------------- 
      Q
  Q
            Q
        Q
Q
              Q
          Q
    Q
 ---------------- 
    Q
          Q
  Q
            Q
Q
      Q
              Q
        Q
 ---------------- 
    Q
        Q
  Q
              Q
Q
            Q
      Q
          Q
 ---------------- 
          Q
              Q
  Q
      Q
Q
            Q
        Q
    Q
 ---------------- 
    Q
              Q
      Q
            Q
Q
          Q
  Q
        Q
 ---------------- 
    Q
        Q
              Q
      Q
Q
            Q
  Q
          Q
 ---------------- 
          Q
    Q
            Q
      Q
Q
              Q
  Q
        Q
 ---------------- 
          Q
    Q
        Q
            Q
Q
      Q
  Q
              Q
 ---------------- 
          Q
    Q
        Q
              Q
Q
      Q
  Q
            Q
 ---------------- 
      Q
              Q
        Q
    Q
Q
            Q
  Q
          Q
 ---------------- 
      Q
            Q
        Q
    Q
Q
          Q
              Q
  Q
 ---------------- 
      Q
          Q
              Q
    Q
Q
            Q
        Q
  Q
 ---------------- 
  Q
      Q
          Q
              Q
    Q
Q
            Q
        Q
 ---------------- 
      Q
  Q
        Q
              Q
          Q
Q
    Q
            Q
 ---------------- 
      Q
  Q
              Q
        Q
            Q
Q
    Q
          Q
 ---------------- 
    Q
            Q
  Q
              Q
        Q
Q
      Q
          Q
 ---------------- 
    Q
          Q
  Q
        Q
              Q
Q
            Q
      Q
 ---------------- 
    Q
          Q
  Q
            Q
        Q
Q
              Q
      Q
 ---------------- 
        Q
            Q
  Q
          Q
    Q
Q
      Q
              Q
 ---------------- 
        Q
            Q
  Q
          Q
    Q
Q
              Q
      Q
 ---------------- 
            Q
      Q
  Q
        Q
              Q
Q
    Q
          Q
 ---------------- 
            Q
      Q
  Q
              Q
          Q
Q
    Q
        Q
 ---------------- 
        Q
            Q
  Q
      Q
              Q
Q
    Q
          Q
 ---------------- 
    Q
          Q
              Q
  Q
      Q
Q
            Q
        Q
 ---------------- 
            Q
    Q
              Q
  Q
        Q
Q
          Q
      Q
 ---------------- 
      Q
            Q
        Q
  Q
          Q
Q
    Q
              Q
 ---------------- 
      Q
          Q
              Q
  Q
            Q
Q
    Q
        Q
 ---------------- 
        Q
    Q
              Q
      Q
            Q
Q
          Q
  Q
 ---------------- 
  Q
            Q
    Q
          Q
              Q
        Q
Q
      Q
 ---------------- 
      Q
  Q
            Q
    Q
          Q
              Q
Q
        Q
 ---------------- 
        Q
  Q
      Q
          Q
              Q
    Q
Q
            Q
 ---------------- 
    Q
            Q
  Q
              Q
          Q
      Q
Q
        Q
 ---------------- 
          Q
      Q
  Q
              Q
        Q
            Q
Q
    Q
 ---------------- 
          Q
    Q
            Q
  Q
      Q
              Q
Q
        Q
 ---------------- 
          Q
    Q
            Q
  Q
              Q
        Q
Q
      Q
 ---------------- 
      Q
            Q
    Q
              Q
  Q
        Q
Q
          Q
 ---------------- 
      Q
  Q
            Q
    Q
          Q
              Q
        Q
Q
 ---------------- 
        Q
  Q
      Q
            Q
    Q
              Q
          Q
Q
 ---------------- 
    Q
        Q
  Q
              Q
          Q
      Q
            Q
Q
 ---------------- 
    Q
          Q
      Q
  Q
              Q
        Q
            Q
Q
 ---------------- 
