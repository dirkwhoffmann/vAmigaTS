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

#### copskip4

    dc.w    COLOR00, $0F0
    dc.w    $6241,$FFFF  ; Skip the next command
    dc.w    $003E,$0000  ; Illegal write (Copper stops)
    dc.w    COLOR00, $FF0
    dc.w    COLOR00, $F00
    
This test skips an illegal write. Although the write is omitted, the resulting image shows that the Copper still stops (as it would if the SKIP command wouldn't be there).


Dirk Hoffmann, 2019
