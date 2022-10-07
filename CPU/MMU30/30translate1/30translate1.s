	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE1 Short: A->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	move.l  rangeA_reloc,a2				
	move.l 	#$00D00001,(a2)

	; Enable the MMU
	jsr setupTC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte
