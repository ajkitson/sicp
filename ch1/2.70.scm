; The following eight symboel alphabet with associated relative frequencies was designed to efficiently encode the lyrics of 1950s
; rock songs. (Note that the "symbols" of an "alphabet" need not be individual letters.)

; A 	2
; BOOM 	1
; GET 	2
; JOB 	2
; NA 	16
; SHA 	3
; YIP 	9
; WAH 	1

; Use generate-huffman-tree (exercise 2.69) to generate a corresponding huffman tree, and use encode (exercise 2.68) to encode the 
; following message:

; Get a job 
; Sha na na na na na na na na
; Get a job
; Sha na na na na na na na na
; Wah yip yip yip yip yip yip yip yip yip 
; Sha boom 

; How many bits are required for the encoding? What is the smallest number of bits that would be needed to encode this song if we used
; a fixed length code for the eight symbol alphabet?
; ========
; Here's we've got the tree:
(define song-tree (generate-huffman-tree '((A 2) (BOOM 1) (GET 2) (JOB 2) (NA 16) (SHA 3) (YIP 9) (WAH 1))))

; And let's put the list in its own variable:
(define song-message '(Get a job Sha na na na na na na na na Get a job Sha na na na na na na na na Wah yip yip yip yip yip yip yip yip yip Sha boom))

; Here's the encoded version:
1 ]=> (encode song-message song-tree)
;Value 15: (1 1 1 1 1 1 1 0 0 1 1 1 1 0 1 1 1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 1 1 1 1 0 1 1 1 0 0 0 0 0 0 0 0 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1 1 0 1 1)

; It is 84 bits long:
1 ]=> (length (encode song-message song-tree))
;Value: 84

; How long would it be with a fixed length encoding? There are 8 symbols in the language, so we would need 3 bits per symbol.
; There are 36 symbols in the message, we would need 3 * 36, or 108 bits with a fixed length encoding. 