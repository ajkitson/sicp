; As a large system with generic operations evolves, new types of data objects or new operations may be needed. For each of the three 
; strategies--generic operations with explicit dispatch, data-directed style, and message-passing style--describe the changes that must
; be made to a system in order to add new types or new operations. Which organization would be most appropriate for a system in which 
; new types must often be added? Which would be most appropriate for a system in which new operations must often be added?
; =====
; Let's go through each of the three types and then answer the last two questions:
;
; A. Generic operations with explicit dispatch
; 	This is when the operation itself knows that different types of data are handled differently. It is the operation's responsibility
; 	to detect what type of data it was given and handle it appropriately. It might detect data types based on tags or whatever
; 	predicates are relevant to the data (e.g. number? variable?). 
;
;	With this style, each operation holds knowledge of the data types it must handle. Knowledge of all the data types in the system
; 	is thus spread out across all the operations. When a new data type is added, each operation must be updated to test for the new
; 	data type and handle it appropriately.
;
;	New operations are a bit easier to add. You just create your new operation and make sure that it handles all the existing data
;	types. 
;
; B. Data-directed style.
;	In this style, the operations do not need to be aware of all the data types in the system. We centralize the knowledge of which
;	procedures work on which types of data in a central table. We then have generic procedures that will, given data and the operation
; 	to perform on the data, figure out what type of data it is dealing with and look up the appropriate procedure to perform the 
; 	specified operation on the given data. You can use tags to indicate what type any given data is.
;
;	Adding new data types is relatively simple. You define the operations that you can perform on that type of data, write procedures
;	to perform those operations, and then put the procedures in the central table so they can be looked up based on operation and
; 	type.
;
;	New operations is basically the same. You define the procedures for the data types the new operation applies to and register 
; 	those combos in the central table.
;
;	Oh, and you need to make sure you consistently tag the data so it's identifiable by the generic procedures.
;
; C. Message-passing style
; 	In this style, the data knows how it should be handled. For example, when you create a complex number, your new complex number
; 	"knows" how to retrieve its magnitude or real part. You just need to ask it to do so by passing a message to it. Knowledge
;	of the different operations is internal to the constructors.
;
;	To add a new type, you would just create a constructor and make sure that constructor had all the operations that are allowed
; 	for that type. 
;
;	To add a new operation, you would have to add the operation individually to the constructors for each data type the new 
;	operation applies to. In this way, it's sort of the converse to the generic operations with explicit dispatch style.
;
;
; D. Which organization is most appropriate for a system in which new types are often added?
;	You would want to use the data-directed or message-passing style. The data-directed style is nice because you can easily
;	define a new data type and the operations that should be used for it without having to touch a lot of code. You just need
;	to create an install package that updates the central table. 
;	
;	The message-passing style also works well here because you can just create a new constructor for the new type, and you don't
;	have the overhead of setting up the generic lookup system. But if you are also adding operations often, then it can become
;	unwieldy as you have to update all the constructors with the new operation.
;
; 	The generic operations with explicit dispatch is the most cumbersome because if you add a new type you have to update all 
; 	the generic procedures to incorporate this new type.
;
; E. Which organization is most appropriate for a system in which new operations are often added?
;	You would want to use data-directed or generic operations with explicit displatch. Again, data-directed takes some setup--you
;	need the centralized dispatch system--but once it's there extending it is very simple. You just define the procedures each 
;	data type needs for the new operation and install them centrally.
;
;	Generic procedures, if you only have a limited and stable number of data types, is also simple. You just write your new 
;	operation and how to handle it for the different data types. This is the same code you would register centrally in a data-
;	directed system, but here there type checking is done in the procedure itself.
;
;	Basically, the data-directed system is the most extendible. But it could be overkill. If your data types are few and stable, it
;	might be easier to do generic procedures. If your operations are few and stable, it might be easier to do message-passing.
; 	But if you need to extend along both dimensions, then data-directed is the best bet.




