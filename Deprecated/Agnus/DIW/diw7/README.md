## Objective

This test changes the background color at the bottom of the screen. It's sole purpose is to visualize the last line that is shown by emulators. 

## Findings

SAE hides some PAL lines, UAE shows even less. 

## Copper list

	dc.w    DIWSTRT,$6781
	dc.w	DIWSTOP,$7FC1 ; Largest possible vertical value
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"
	
	dc.w    $ffdf,$fffe  ; Cross vertical boundary
	dc.w    $3501,$FFFE  ; Line $135 (last in SAE)
	dc.w    COLOR00,$F00

	dc.w    $3601,$FFFE  ; Line $136 (last in UAE)
	dc.w    COLOR00,$FF0 

	dc.w    $3701,$FFFE  ; Line $137 (not visible in SAE or UAE)
	dc.w    COLOR00,$0FF

	dc.l	$fffffffe
