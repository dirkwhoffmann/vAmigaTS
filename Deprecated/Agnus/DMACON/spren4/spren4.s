	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
MAIN:
	jsr 	setup

.mainLoop:
	jsr     synccpu
	bra.b	.mainLoop

	include "../spren.i"

copper:
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

	dc.w    $3801,$FFFE 
	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, (1<<12)|$600

	;
	; Sprite 1
	; 

	dc.w    $3B41,$FFFE 
	RULER
   
    dc.w    $3CBB,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $3EBD,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $40BF,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $42C1,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $44C3,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $46C5,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $48C7,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

    dc.w    $4CBB,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $4EBD,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $50BF,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $52C1,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $54C3,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $56C5,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $5C7,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

    dc.w    $5CBB,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $5EBD,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $60BF,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $62C1,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $64C3,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $66C5,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $68C7,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6901,$FFFE 
	dc.w    DMACON,$0020

	dc.w    $6C41,$FFFE 
	RULER

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0