## Objective

Shows that if DIWSTRT and DIWSTOP are set to the same vertical positon, STOP wins. Otherwise, a third stripe would appear in the test picture.

## Copper list

	dc.w    DIWSTRT,$8081
	dc.w	DIWSTOP,$81c1 ; Display 1 line
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	dc.w    $8301,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$A081
	dc.w	DIWSTOP,$B0c1 ; Displays 16 lines

	dc.w	$B101,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$C081
	dc.w    DIWSTOP,$C0C1 ; Displays nothing, because STOP is dominant

	dc.l	$fffffffe
