## Objective

This test modifies the vertical display coordinates (DIWSTRT and DIWSTOP) around the trigger positons. 

## Copper list

	dc.w    DIWSTRT,$6c81
	dc.w	DIWSTOP,$80c1 ; (1)
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	; Try to modify DIWSTOP around the trigger position
	dc.w    $7FDF,$FFFE   ; WAIT 
	dc.w	DIWSTOP,$2cc1 ; Too late. Stop position (1) is used

	dc.w	$8801,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$E081
	dc.w    DIWSTOP,$0cC1

	dc.w    $ffdf,$fffe   ; Cross vertical boundary

	dc.w    $0bDD,$FFFE   ; WAIT 
	dc.w    DIWSTOP,$7FC1 ; Just in time. New stop position ($17F) takes effect

	dc.l	$fffffffe

