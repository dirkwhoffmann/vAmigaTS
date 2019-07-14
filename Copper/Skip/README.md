## Objective

This test suite verfies particular aspects of the SKIP command.

#### copstrt1 and copstrt2

Verify the first possible trigger coordinate by using a SKIP statement.

First two instructions of the copstrt1 Copper list: 

	dc.w	$000B,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

First two instructions of the copstrt2 Copper list: 

	dc.w	$000D,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

The reference images reveal that the video beam counter is greater or equal than $000B, but less than $000D when the Copper processes the first instruction. 

#### copskip1

Checks the SKIP with various coordinates

#### copskip2

Same as copskip1 with an additional fifth bitplane enabled.

#### copskip3

Checks the behaviour of a SKIP command followed by a MOVE command and a WAIT command. 

The reference image reveals that only MOVE commands can skipped. 


Dirk Hoffmann, 2019