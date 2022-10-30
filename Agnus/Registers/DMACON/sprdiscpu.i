copper:
	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, $0200
	dc.w    $3B01,$FFFE 
	dc.w    BPLCON0, $1200

	;
	; Sprite 1
	; 

	dc.w    $3B41,$FFFE 
	RULER
   
    dc.w    $3CBB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $3DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $3EBD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $3FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $40BF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $41C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $42C1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $43C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $44C3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $45C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $46C5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $47C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $48C7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $49C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 2
	; 

	dc.w    $4B41,$FFFE 
	RULER

    dc.w    $4CBF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $4DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4EC1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $4FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $50C3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $51C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $52C5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $53C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $54C7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $55C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $56C9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $57C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $56CB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $59C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 3
	; 

	dc.w    $5B41,$FFFE 
	RULER

    dc.w    $5CC3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $5DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5EC5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $5FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $60C7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $61C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $62C9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $63C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $64CB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $65C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $66CD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $67C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $68CF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $69C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 4
	; 

	dc.w    $6B41,$FFFE 
	RULER

    dc.w    $6CC7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $6DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6EC9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $6FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $70CB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $71C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $72CD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $73C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $74CF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $75C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $76D1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $77C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $78D3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $79C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 5
	; 

	dc.w    $7B41,$FFFE 
	RULER

    dc.w    $7CCB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $7DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $7ECD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $7FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $80CF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $81C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $82D1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $83C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $84D3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $85C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $86D5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $87C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $88D7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $89C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 6
	; 

	dc.w    $8B41,$FFFE 
	RULER

    dc.w    $8CCF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $8DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $8ED1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $8FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $90D3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $91C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $92D5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $93C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $94D7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $95C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $96D9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $97C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $98DB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $99C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 7
	; 

	dc.w    $9B41,$FFFE 
	RULER

    dc.w    $9CD3+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $9DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9ED5+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $9FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A0D7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $A1C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A2D9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $A3C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A4DB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $A5C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A6DD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $A7C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A8DF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $A9C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 8
	; 

	dc.w    $AB41,$FFFE 
	RULER

    dc.w    $ACD7+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $ADC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $AED9+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $AFC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B0DB+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $B1C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B2DD+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $B3C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B4DF+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $B5C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B6E1+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $B7C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B901+OFFSET,$FFFE
	dc.w    INTREQ, $8008       ; Level 2 IRQ
	dc.w    $B9C1,$FFFE 
	dc.w    DMACON,$8020

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 	51201,0