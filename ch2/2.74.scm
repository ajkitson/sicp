; Insatiable Enterprises, Inc., is a hghly decentralized conglomerate company consisting of a large number of independent divisions
; located all over the world. The company computer facilities have just been connected by means of a clever networking interfacing
; scheme that makes the entire network appear to any user to be a single computer. Insatiable's president, in her first attempt to 
; exploit the ability of the network to extract adminstrative information from division files, is dismayed to discover that , although
; all the division files have been implemented as data structures in SCheme, the particular data structures used varies from division
; to division. A meeting of division managers is hastily called to saerch for a strategy to integrate the files that will satisfy
; headquarters' needs while preserving the existing autonomy of the divisions.

; Show how such a strategy can be implemented with data-directed programming. As an example, suppose that each division's personnel
; records consist of a single file, which contains a set of records keyed on employees' names. The structure of the set varies from
; division to division. Furthermore, each employee's record is itself a set (structured differently from division to division) that
; contains information keyed under identifiers such as address and salary. In particular:

; a. Implement for headquarters a get-record procedure that retrieves a specified employee's record from a specified personnel file.
; 	The procedure should be applicable to any division's file. Explain how the individual division's files should be structured.
; 	In particular, what type of information must be supplied?

; b. Implement for headquarters a get-salary procedure that returns the salary information for a given employee's record from any
; 	division's personnel file. How should the record be structured in order to make this operation work?

; c. Implement for headquarters a find-employee-record procedure This should search all divisions' files for the record of a given
; 	employee and return the record. Assume that this procedure takes as arguments an employee's name and a list of all the 
; 	divisions' files.

; d. What Insatiable takes over a new company, what changes must be made in order to incorporate the new personnel information into
; 	the central system?
;
; =======
; What we need to do is set it up so that each division has its own package of procedures that define how its records are structured
; and how to interact with them. These are registered centrally uner the operation and the division name. The files are all 
; tagged with the division it belongs to and this allows us to look up the procedure that division uses for any given operation.
;
; a. We define a get-record procedure that just uses get to look up the division-specific version of get-record and
;	apply that. We could use apply-generic, but name shouldn't need to be tagged and apply-generic assumes the inputs have tags.
; 	Using get is just as simple. The file can be structured however the division wants as long as it can use the name to look up 
; 	an employee record and the file is tagged (using attach-tag) to indicate its division (and therefor the procedures that should
;	be used to interact with it).

(define (get-record name file)
	((get 'get-record (type-tag file)) name (contents file)))

; This allows each division to implement a get-record that works for them. The get-record procedure doesn't need to be aware of the
; packaging--it just needs to be installed correctly. Though installing it correctly means tagging the employee record when it's 
; returned.
;
; For example, Division A implements files as unordered lists:
(define (install-divisionA-package)
	(define (get-record name file)
		(cond ((null? file) false)
			((eq? name (car file)) (car file))
			(else (get-record name (cdr file)))))
	(define (tag x) (attach-tag 'divisionA x))
	(put 'get-record 'divisionA 
		(lambda (name file)  ; tag record if we find one, not otherwise
			(let (employee (get-record name file)) 
				(if (not employee)
					false
					(tag employee))))))

; b. For get-salary and other procedures that look up employee info from a record, we'll use apply-generic. apply-generic will handle 
; passing the appropriate division and stripping the tag from employee-rec.
(define (get-salary employee-rec)
	(apply-generic 'get-salary employee-rec))

; c. For find-employee-record, we'll just go through each file and use get-record (the generic verion) to see if we can find the 
; 	record in each file.
(define (find-employee-record name files)
	(if (null? files)
		false
		(or (get-record name (car files)) ; check first file and return that if we find it
			(find-employee-record name (cdr files))))) ; check remaining files otherwise

; d. When insatiable takes over a new company, the company must create a package that defines how to interact with its database and
; 	install that alongside the rest of Insatiable's division packages. There needs to be a get-record procedure and a 
; 	set of procedures to look up information from a record. These each need to conform to the signatures of the rest of the divisions
; 	but can do whatever they want internally. E.g. get-record must take a name and file, that's it.





