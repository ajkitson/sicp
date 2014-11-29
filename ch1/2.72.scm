; Consider the encoding procedure that you designed in exercise 2.68. What is the order of growth in the number of steps needed to
; encode a symbol? Be sure to include the number of steps needed to search the symbol list at each node encountered. To answer this
; question in general is difficult. Consider the special case where the relative frequencies of the n symbols are as described in 
; exercise 2.71, and give the order of growth (as a function of n) of the number of steps needed to encode the most frequent and
; least frequent symbols in the alphabet.
; ======
; The number of steps needed to encode a single symbol depends on:
;	- how many symbols are in the tree
; 	- the layout of the tree (balanced or unbalanced)
;	- the relative frequency of the symbol
; 
; The number of symbols in the tree determines how long it takes to tell whether a symbol is on a given branch. That is, it 
; determines how long it takes to move down a level of the tree. The layout of the tree and relative frequency of the symbol
; determine how many levels we need to move down.
;
; The time each level takes is just the order of growth of our search procedure. We currently have our set implemented as an 
; unordered list and searching it is O(n). However, as we move down the tree, there are fewer and fewer symbols left, so n
; decreases.
;
; Working with the relative frequencies from 2.71 is helpful because it gives us the most unbalanced tree possible. We can 
; use this tree to look at both the best case and worst case running time. 
; 
; The best case is when we have the most frequent symbol in the tree. In that case, we just check the left branch, which 
; is always a leaf node. It has one symbol in its set, so searching it is O(1). We see that it's a mach and return. So,
; best case we're at O(1). Cool!
; 
; Worst-case is much different. Worst-case is when we have the least frequently used symbol. To reach it we must traverse
; n - 1 levels.  At each of these levels we potentially search n - (level number) symbols to see if the symbol we're looking for
; is in the next branch. (For the true worst case, we're assuming that our symbol is the last symbol in each of these sets so we 
; don't end the search early.) So we're looking at the sum of { n, n - 1,... 1 }, or { 1, 2, .... n - 1, n }, which is 
; n(n + 1)/2, for an O(n^2) order of growth.
