; Define the procedure up-split used by corner-split. It is similar to right-split, except that it switches the roles of below and
; beside
; ====
; Writing the procedure itself was simple, but getting the environment set up with the picture language was a pain. Had to switch
; to using DrRacket instead of MIT-scheme and then use this package: 
; http://planet.racket-lang.org/package-source/soegaard/sicp.plt/2/1/planet-docs/sicp-manual/index.html
; Tried using the mit-scheme code for the picture language (https://mitpress.mit.edu/sicp/psets/ps4hnd/readme.html) but couldn't
; get everything to compile correctly after about 30 minutes.

(define (up-split painter n)
	(if (= n 0)
		painter
		(let ((smaller (up-split painter (-n 1))))
			(below painter (beside smaller smaller)))))