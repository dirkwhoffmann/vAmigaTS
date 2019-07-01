## Objective

This test modifies the vertical display coordinates (DIWSTRT and DIWSTOP). It exhibits the following:

- Bitplane DMA is suspended as long as the vertical DIW flipflop is cleared.
- The flipflop can be set and cleared multiple times.

## Copper list

	dc.w    DIWSTRT,$6c81
	dc.w	DIWSTOP,$80c1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$E081
	dc.w    DIWSTOP,$2cC1

	dc.l	$fffffffe


