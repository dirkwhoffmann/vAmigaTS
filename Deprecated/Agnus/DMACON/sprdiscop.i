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
   
    dc.w    $3D09+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $3DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $3F0B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $3FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $410D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $41C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $430F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $43C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4511+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $45C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4713+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $47C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4915+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $49C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

    dc.w    $4D0D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $4F0F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $4FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5111+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $51C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5313+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $53C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5515+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $55C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5717+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $57C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5919+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $59C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

    dc.w    $5D11+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $5F13+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $5FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6115+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $61C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6317+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $63C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6519+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $65C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $671B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $67C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $692D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $69C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 4
	; 

	dc.w    $6C41,$FFFE 
	RULER

    dc.w    $6D15+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $6F17+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $7119+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $71C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $731B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $73C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $751D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $75C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $771F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $77C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $7921+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $79C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 5
	; 

	dc.w    $7C41,$FFFE 
	RULER

    dc.w    $7D19+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $7F1B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $6FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $811D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $71C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $831F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $73C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $8521+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $75C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $8723+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $77C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $8925+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $79C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 6
	; 

	dc.w    $8C41,$FFFE 
	RULER

    dc.w    $8D1D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $8DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $8F1F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $8FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9121+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $91C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9323+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $93C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9525+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $95C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9727+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $97C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9929+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $99C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 7
	; 

	dc.w    $9C41,$FFFE 
	RULER

    dc.w    $9D21+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $9DC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $9F23+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $9FC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A125+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $A1C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A327+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $A3C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A529+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $A5C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A72B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $A7C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $A92D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $A9C1,$FFFE 
	dc.w    DMACON,$8020

	; 
	; Sprite 8
	; 

	dc.w    $AC41,$FFFE 
	RULER

    dc.w    $AD25+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $ADC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $AF27+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $AFC1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B129+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $B1C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B32B+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $B3C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B52D+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $B5C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B72F+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $B7C1,$FFFE 
	dc.w    DMACON,$8020

    dc.w    $B931+OFFSET,$FFFE
	dc.w    DMACON,$0020
	dc.w    $B9C1,$FFFE 
	dc.w    DMACON,$8020

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0
	