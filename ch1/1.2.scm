; Translate the following expression into prefix form:
; (5 + 4 + (2 - (3 - (6 + 4/5)))) / 3(6 - 2)(2 - 7)

(/ (+ 5 4 (- 2 (- 3 (+ 6 (/ 4 5)))))
	(* 3 (- 6 2) (- 2 7)))


;============
1 ]=> (load "1.1.2.scm")

;Loading "1.1.2.scm"... done
;Value: -37/150

; 14.8 / -60 is what I got by hand, testing to make sure it's the same as -37/150
1 ]=> (/ 14.8 -60)

;Value: -.24666666666666667

1 ]=> (* 1.0 -37/150)  ; * 1.0 to force conversion to real number

;Value: -.24666666666666667

