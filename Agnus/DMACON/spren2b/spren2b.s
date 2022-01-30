	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
MAIN:
	jsr 	setup

.mainLoop:
	jsr     synccpu
	bra.b	.mainLoop

	include "../spren_b.i"

copper:
	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, (1<<12)|$600
sprite0:
	dc.w    SPR0PTL, $0000
sprite1:
	dc.w    SPR1PTL, $0000
sprite2:
	dc.w    SPR2PTL, $0000
sprite3:
	dc.w    SPR3PTL, $0000
sprite4:
	dc.w    SPR4PTL, $0000
sprite5:
	dc.w    SPR5PTL, $0000
sprite6:
	dc.w    SPR6PTL, $0000
sprite7:
	dc.w    SPR7PTL, $0000

	;
	; Sprite 1
	; 

	dc.w    $3C41,$FFFE 
	RULER
   
    dc.w    $3D01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $3D09,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $3F01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $3F0B,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4101,$FFFE
	dc.w    DMACON,$0020
	dc.w    $410D,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4301,$FFFE
	dc.w    DMACON,$0020
	dc.w    $430F,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4501,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4511,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4701,$FFFE
	dc.w    DMACON,$0020
	dc.w    $3713,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4901,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4915,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

    dc.w    $4D01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4D01,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4F01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4F11,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5101,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5113,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5301,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5315,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5501,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5517,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5701,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5719,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5901,$FFFE
	dc.w    DMACON,$0020
	dc.w    $591B,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

    dc.w    $5D01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5D15,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5F01,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5F17,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6101,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6119,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6301,$FFFE
	dc.w    DMACON,$0020
	dc.w    $631B,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6501,$FFFE
	dc.w    DMACON,$0020
	dc.w    $651D,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6701,$FFFE
	dc.w    DMACON,$0020
	dc.w    $671F,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6901,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6921,$FFFE 
	dc.w    DMACON,$8020

	dc.w    $6C41,$FFFE 
	RULER

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0
	