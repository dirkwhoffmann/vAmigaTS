	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts and DMA
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Crosscheck with initialized memory
.initloop:
   	move.w  #3500,d3
	lea     $200000,a2 
.initloop2:
	move.w  #$FF0,(a2)+
	dbra    d3,.initloop2

.mainloop: 
   	move.w  #3500,d3
	lea     $200000,a2 
	jsr     synccpu

.loop1:
	move.w  (a2)+,COLOR00(a1)
	dbra    d3,.loop1
	move    #$0,COLOR00(a1)
	bra.s   .mainloop

	synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the top of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$4000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  
	rts