	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE6 Short: A->B->C->I->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	move.l	rangeAFF_reloc,a2
	lea     newtabled,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)

	; Enable the MMU (TIAD = 0 is the test subject here)
	;   8      : E = 1
	;   0      : FCL = 0, SRE = 0
	;   C      : PS = 4KB
	;   84440  : IS = 8, TIA = 4, TIAB = 4, TIAC = 4, TIAD = 0
	lea 	tcval,a2
	move.l  #$80C84440,(a2)  
	pmove   (a2),TC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte

tcval:
	dc.b    $00, $00, $00, $00
	align   4
newtabled:
	dc.b    $00, $DF, $F0, $01
