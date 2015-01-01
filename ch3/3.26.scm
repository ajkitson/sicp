; To search a table as implemented above, one needs to scan through a list of records. This is basically the unordered list representation of
; section 2.3.3. For large tables, it may be more efficient to structure the table in a different manner. Describe a table implementation
; where the (key, value) records are organized using a binary tree, assuming that keys can be ordered in some way (e.g. numerically
; or alphabetically.) (Compare exercise 2.66 of chapter 2).
; =======
; The question asks us to describe, not implement, so we'll stick to description. 
;
; This is actually pretty straight-forward. Because our operations on records (looking up by key,value or inserting by key,value) are
; concentrated in add-to-table! and assoc, we can swap out the table representation in them without having to update insert! or lookup.
;
; We could pull the binary tree code directly from what we wrote in 2.3.3 and wire it in with a few modifications. Our 2.3.3 
; implementation of sets as binary trees has two procedures we'll want to modify and use. 
;
; First, there is element-of-set? which does a basic lookup to see if a given value is in the set. There are two modifications we need
; to make. The element-of-set? just returns true or false. This is because it's checking whehter the value itself is in the set, not
; whether an obj with a corresponding key is in the set. So we would have to return the object when we find it. The second modification
; is in how we evaluate whether the key of object in the set is greater than, less than, or equal to our key. So we need to supply
; a comparison operation (or set of operations) to compare our search key and an object and tell us gt, lt, equal to. To do this, of
; course, we need to get the key from the object in the set. We can either update element-of-set? to do that, or leave it up to the 
; comparison procedure. I would leave it up to the comparison procedure.
;
; The second procedure we're interested in is adjoin-set. We would have to make similar modifications as those we did for element-of-set?
;
; We would have to update make-table to take a comparison procedure (or set of them) that we can pass on to element-of-set?
; and adjoin-set.
;
; Finally, we would have to deal with the fact that, as written, adjoin-set returns a new object and does not modify the old one.
; This should work find since we use set-cdr! to modify the table, references to the table will stay the same and only the table
; needs to know the reference for the new set... actually, this is exactly the same situation we currently have when we cons the new
; record to the front of the list. So not an issue at all. 
