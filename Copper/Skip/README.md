## Objective

This test suite verifies some Copper timing properties.

#### copstrt1 and copstrt2

Verify the first possible trigger coordinate by using a SKIP statement.

First two instructions of the copstrt1 Copper list: 

	dc.w	$000B,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

First two instructions of the copstrt2 Copper list: 

	dc.w	$000D,$FFFF  ; SKIP
	dc.w	COLOR00, $F00

The reference images reveal that the video beam counter is greater or equal than $000B, but less than $000D when the Copper processes the first instruction. 

#### copstrt3

Checks the behaviour of a SKIP command followed by a MOVE command and a WAIT command. 

The reference image reveals that only MOVE commands can skipped. 

#### copwait1 and copwait2

Checks the behaviour of the WAIT command with waiting positions near it's own execution cycle. 

#### copwait3 and copwait4

Same as copwait1 and copwait2 with a fifth bitplane enabled.

#### copwait5 and copwait6

Checks the WAIT command with horizontal positions around 0 and $E2, respectively. 


Dirk Hoffmann, 2019