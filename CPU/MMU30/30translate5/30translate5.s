	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE5 Short: A->B->C->D->I->Mem', 0
	even
	
trap0:
	; Patch the MMU table (nothing to do here)

	; Enable the MMU
	jsr setupTC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte
	