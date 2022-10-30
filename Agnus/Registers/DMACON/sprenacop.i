copper:
	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, $0200
	dc.w    $3C01,$FFFE 
	dc.w    BPLCON0, $1200

	;
	; Sprite 1
	; 

	dc.w    $3C41,$FFFE 
	RULER
   
	dc.w    $3D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $3D09+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $3F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $3F0B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $410D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $430F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $4511+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $4713+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $4915+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

	dc.w    $4D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $4D0D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $4F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $4F0F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5111+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5313+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5515+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5717+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5919+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

	dc.w    $5D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5D11+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $5F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $5F13+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $6115+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $6317+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $6519+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $671B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $692D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 4
	; 

	dc.w    $6C41,$FFFE 
	RULER

	dc.w    $6D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $6D15+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $6F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $6F17+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $7119+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $731B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $751D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $771F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $7921+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 5
	; 

	dc.w    $7C41,$FFFE 
	RULER

	dc.w    $7D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $7D19+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $7F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $7F1B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $811D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $831F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $8521+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $8723+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $8925+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 6
	; 

	dc.w    $8C41,$FFFE 
	RULER

	dc.w    $8D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $8D1D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $8F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $8F1F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9121+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9323+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9525+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9727+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9929+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 7
	; 

	dc.w    $9C41,$FFFE 
	RULER

	dc.w    $9D01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9D21+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $9F01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $9F23+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $A101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $A125+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $A301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $A327+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $A501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $A529+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $A701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $A72B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $A901,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $A92D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	; 
	; Sprite 8
	; 

	dc.w    $AC41,$FFFE 
	RULER

	dc.w    $AD01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $AD25+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $AF01,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $AF27+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $B101,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $B129+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $B301,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $B32B+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $B501,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $B52D+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $B701,$FFFE 
	dc.w    DMACON,$0020
    dc.w    $B72F+OFFSET,$FFFE
	dc.w    DMACON,$8020

	dc.w    $B901,$FFFE 
	dc.w    DMACON,$0020
	dc.w    $B9C1,$FFFE 
	dc.w    DMACON,$8020

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0
	