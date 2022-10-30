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
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $3D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $3EBD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $3F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $40BF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $42C1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $44C3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $46C5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $3701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $48C7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 2
	; 

	dc.w    $4B41,$FFFE 
	RULER

    dc.w    $4CBF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $4EC1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $4F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $50C3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $52C5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $54C7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $56C9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $57C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $56CB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 3
	; 

	dc.w    $5B41,$FFFE 
	RULER

    dc.w    $5CC3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $5EC5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $5F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $60C7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $62C9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $64CB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $66CD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $68CF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 4
	; 

	dc.w    $6B41,$FFFE 
	RULER

    dc.w    $6CC7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $6EC9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $70CB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $72CD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $74CF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $76D1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $78D3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 5
	; 

	dc.w    $7B41,$FFFE 
	RULER

    dc.w    $7CCB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $7ECD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $7F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $80CF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $82D1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $84D3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $86D5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $88D7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 6
	; 

	dc.w    $8B41,$FFFE 
	RULER

    dc.w    $8CCF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $8ED1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $8F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $90D3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $92D5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $94D7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $96D9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $98DB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 7
	; 

	dc.w    $9B41,$FFFE 
	RULER

    dc.w    $9CD3+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $9ED5+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $9F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $A0D7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $A101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $A2D9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $A301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $A4DB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $A501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $A6DD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $A701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $A8DF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $A901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 8
	; 

	dc.w    $AB41,$FFFE 
	RULER

    dc.w    $ACD7+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $AD01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $AED9+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $AF01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $B0DB+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $B101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $B2DD+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $B301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $B4DF+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $B501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $B6E1+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $B701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $B901+OFFSET,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $B901,$FFFE 
	dc.w    DMACON,$0020

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 	51201,0