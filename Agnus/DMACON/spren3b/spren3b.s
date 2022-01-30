	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
MAIN:
	jsr 	setup

.mainLoop:
	jsr     synccpu
	bra.b	.mainLoop

	include "../spren_b.i"

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
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $3DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $3EBD,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $3FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $40BF,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $41C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $42C1,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $43C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $44C3,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $45C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $46C5,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $37C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $48C7,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $49C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

    dc.w    $4CBB,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $4DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4EBD,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $4FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $50BF,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $51C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $52C1,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $53C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $54C3,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $55C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $56C5,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $57C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5C7,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $59C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

    dc.w    $5CBB,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $5DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5EBD,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $5FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $60BF,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $61C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $62C1,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $63C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $64C3,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $65C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $66C5,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $67C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $68C7,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $69C1,$FFFE 
	dc.w    DMACON,$8020

	dc.w    $6C41,$FFFE 
	RULER

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0