## Objective

This test suite verifies some Copper timing properties

#### copstrt1 and copstrt2

Test the first possible trigger coordinate by using a SKIP statement.

First two instructions of the copstrt1 Copper list: 

	dc.w	$000B,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

First two instructions of the copstrt2 Copper list: 

	dc.w	$000D,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

The test images reveal that the video beam counter is greater or equal than $000B, but less than $000D when the Copper processes the first instruction. 



Dirk Hoffmann, 2019