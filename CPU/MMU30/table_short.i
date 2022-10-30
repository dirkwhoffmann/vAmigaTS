setupMMU:

	; Align the start address of the MMU table to a multiple of 0x1000.
	; This is what Dave Haynie is doing in setCPU. I am unsure what the 
	; miminal alignment constraints are. 

	lea 	mmutable,a4
	move.l  a4,d4
	add.l   #$1000,d4
	and.l   #$FFFFF000,d4
	move.l  d4,a4				; a4 contains the MMU table start

	; Copy the MMU table to the aligned start address
	lea     tableA,a2
	move.l  a4,a3
	move.l  #256,d0				; Simply copy 1KB (which is way more than needed)
.loop:
	move.l  (a2)+,(a3)+
	dbra    d0,.loop
	
	; Compute the relocated addresses for labelled table entries
	move.l  a4,tableA_reloc
	move.l  a4,a2				
	add.l 	#(rangeA-tableA),a2
	move.l 	a2,rangeA_reloc
	move.l  a4,a2				
	add.l 	#(tableB-tableA),a2
	move.l 	a2,tableB_reloc
	move.l  a4,a2				
	add.l 	#(rangeAF-tableA),a2
	move.l 	a2,rangeAF_reloc
	move.l  a4,a2				
	add.l 	#(tableC-tableA),a2
	move.l 	a2,tableC_reloc
	move.l  a4,a2				
	add.l 	#(rangeAFF-tableA),a2
	move.l 	a2,rangeAFF_reloc
	move.l  a4,a2				
	add.l 	#(tableD-tableA),a2
	move.l 	a2,tableD_reloc
	move.l  a4,a2				
	add.l 	#(rangeAFF1-tableA),a2
	move.l 	a2,rangeAFF1_reloc
	move.l  a4,a2				
	add.l 	#(pagedesc-tableA),a2
	move.l 	a2,pagedesc_reloc

	; Install pointer to table B
	move.l  rangeA_reloc,a2
	move.l  tableB_reloc,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)

	; Install pointer to table C
	move.l  rangeAF_reloc,a2
	move.l  tableC_reloc,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)

	; Install pointer to table D
	move.l  rangeAFF_reloc,a2
	move.l  tableD_reloc,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)

	; Install a page indirect descriptor in table D
	move.l  rangeAFF1_reloc,a2
	move.l  pagedesc_reloc,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)
	
	; Disable the MMU
	move.l  a4,a2
	add.l   #$2000,a2
	move.l  #0,(a2)  
	move.l  #0,$4(a2)  
	pmove   (a2),TC
	nop

	; Invalidate the cache (Just for safetly. Most likely not needed)
	pflusha

	; Reset other MMU registers  (Just for safetly. Most likely not needed)
	pmove   (a2),MMUSR
	pmove   (a2),TT0
	pmove   (a2),TT1

	; Install the Cpu Root Pointer (CRP)
	move.l  #$80000002,(a2) ; Write L/U and DT (short table)
	; move.l  #$007F0002,(a2) ; Write L/U and DT (short table)
	move.l  a4,$4(a2)		; Write table pointer
	pmove   (a2),CRP
	pmove   (a2),SRP
	rts

setupTC:
	move.l  a4,a2
	add.l   #$2000,a2

	; Install the Translate Control Register (TC)
	;   8      : E = 1
	;   0      : FCL = 0, SRE = 0
	;   8      : PS = 256 bytes
	;   84444  : IS = 8, TIA = 4, TIAB = 4, TIAC = 4, TIAD = 4 
	move.l  #$80884444,(a2)  
	pmove   (a2),TC
	nop
	
	; At this point, the MMU is active and maps $Axxxxx to $Dxxxxx
    rts
	
	align 4
tableA:
	dc.b    $00, $00, $00, $01 ; 0
	dc.b    $00, $10, $00, $01 ; 1
	dc.b    $00, $20, $00, $01 ; 2   
	dc.b    $00, $30, $00, $01 ; 3
	dc.b    $00, $40, $00, $01 ; 4
	dc.b    $00, $50, $00, $01 ; 5
	dc.b    $00, $60, $00, $01 ; 6
	dc.b    $00, $70, $00, $01 ; 7
	dc.b    $00, $80, $00, $01 ; 8
	dc.b    $00, $90, $00, $01 ; 9
rangeA:
	dc.b    $00, $00, $00, $00 ; 10  -> Table B
	dc.b    $00, $B0, $00, $01 ; 11
	dc.b    $00, $C0, $00, $01 ; 12
	dc.b    $00, $D0, $00, $01 ; 13
	dc.b    $00, $E0, $00, $01 ; 14
	dc.b    $00, $F0, $00, $01 ; 15

	align 4
tableB:
	dc.b    $00, $D0, $00, $01 ; 0
	dc.b    $00, $D1, $00, $01 ; 1
	dc.b    $00, $D2, $00, $01 ; 2   
	dc.b    $00, $D3, $00, $01 ; 3
	dc.b    $00, $D4, $00, $01 ; 4
	dc.b    $00, $D5, $00, $01 ; 5
	dc.b    $00, $D6, $00, $01 ; 6
	dc.b    $00, $D7, $00, $01 ; 7
	dc.b    $00, $D8, $00, $01 ; 8
	dc.b    $00, $D9, $00, $01 ; 9
	dc.b    $00, $DA, $00, $01 ; 10 
	dc.b    $00, $DB, $00, $01 ; 11
	dc.b    $00, $DC, $00, $01 ; 12
	dc.b    $00, $DD, $00, $01 ; 13
	dc.b    $00, $DE, $00, $01 ; 14
rangeAF:
	dc.b    $00, $00, $00, $00 ; 15  -> Table C

	align 4
tableC:
	dc.b    $00, $DF, $00, $01 ; 0
	dc.b    $00, $DF, $10, $01 ; 1
	dc.b    $00, $DF, $20, $01 ; 2   
	dc.b    $00, $DF, $30, $01 ; 3
	dc.b    $00, $DF, $40, $01 ; 4
	dc.b    $00, $DF, $50, $01 ; 5
	dc.b    $00, $DF, $60, $01 ; 6
	dc.b    $00, $DF, $70, $01 ; 7
	dc.b    $00, $DF, $80, $01 ; 8
	dc.b    $00, $DF, $90, $01 ; 9
	dc.b    $00, $DF, $A0, $01 ; 10 
	dc.b    $00, $DF, $B0, $01 ; 11
	dc.b    $00, $DF, $C0, $01 ; 12
	dc.b    $00, $DF, $D0, $01 ; 13
	dc.b    $00, $DF, $E0, $01 ; 14
rangeAFF:
	dc.b    $00, $00, $00, $00 ; 15  -> Table D

	align 4
tableD:
	dc.b    $00, $DF, $F0, $01 ; 0
rangeAFF1:
	dc.b    $00, $00, $00, $00 ; 1   -> Page Descriptor
	dc.b    $00, $DF, $F2, $01 ; 2   
	dc.b    $00, $DF, $F3, $01 ; 3
	dc.b    $00, $DF, $F4, $01 ; 4
	dc.b    $00, $DF, $F5, $01 ; 5
	dc.b    $00, $DF, $F6, $01 ; 6
	dc.b    $00, $DF, $F7, $01 ; 7
	dc.b    $00, $DF, $F8, $01 ; 8
	dc.b    $00, $DF, $F9, $01 ; 9
	dc.b    $00, $DF, $FA, $01 ; 10 
	dc.b    $00, $DF, $FB, $01 ; 11
	dc.b    $00, $DF, $FC, $01 ; 12
	dc.b    $00, $DF, $FD, $01 ; 13
	dc.b    $00, $DF, $FE, $01 ; 14
	dc.b    $00, $DF, $FF, $01 ; 15

	align 4
pagedesc:
	dc.b    $00, $DF, $F1, $01

; Table addresses after relocation
tableA_reloc:
	dc.l $0
rangeA_reloc:
	dc.l $0
tableB_reloc:
	dc.l $0
rangeAF_reloc:
	dc.l $0
tableC_reloc:
	dc.l $0
rangeAFF_reloc:
	dc.l $0
tableD_reloc:
	dc.l $0
rangeAFF1_reloc:
	dc.l $0
pagedesc_reloc:
	dc.l $0

mmutable:
	ds.b	$4000
