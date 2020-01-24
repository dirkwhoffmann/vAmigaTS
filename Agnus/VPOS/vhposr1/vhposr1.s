	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	level1InterruptHandler(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	level2InterruptHandler(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4InterruptHandler(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5InterruptHandler(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	level6InterruptHandler(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Install copper list
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),dmacon(a1)

	lea     mainLoop(pc),a3	
mainLoop:
	jmp     (a3)           ; 8 cycles

level1InterruptHandler:    ; Reset bitplane pointers

	move.w  #$3FFF,$DFF09C ; Acknowledge

	lea	    bitplanes(pc),a1
	lea     CUSTOM,a5
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop

	move    #$F,SR         ; Restore SR manually  
	bra 	mainLoop       ; Exit IRQ handler manually		

level2InterruptHandler:    ; SYNC CPU (Wait until HPOS % 7 == 0)

	move.w  #$F0F,$DFF180
	lea     $DFF006,a4
sync:
	andi.w  #$7,(a4)       ; 16 cycles
	bne     sync           ; 10 cycles
	move.w  #$000,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	move.l  #$DFF186,a7    ; Redirect stack pointer to color registers
		                   ; Causes level3InterruptHandler to write SR into DFF180
	move    #$F,SR         ; Restore SR manually  
	bra 	mainLoop       ; Exit IRQ handler manually		

level3InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	move.w  (a4),d0        ; Read VHPOSR

.test0:
	lea	bit0(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w #$CCC,(a0)

.test1:
	lea	bit1(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w #$CCC,(a0)

.test2:
	lea	bit2(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w #$CCC,(a0)

.test3:
	lea	bit3(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w #$CCC,(a0)

.test4:
	lea	bit4(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w #$CCC,(a0)

.test5:
	lea	bit5(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w #$CCC,(a0)

.test6:
	lea	bit6(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w #$CCC,(a0)

.test7:
	lea	bit7(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w #$CCC,(a0)

.test8:

	move.l  #$DFF184,a7   ; Redirect stack pointer to color registers
	                      ; Causes level4InterruptHandler to write PC_HI into DFF180
	move    #$F,SR        ; Restore SR manually  
	move.w  #$000,$DFF180
	bra  	mainLoop      ; Exit IRQ handler manually

;RGB: 
;	DC.W    $F00, $0F0, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $FFF, $400 
;	DC.W    $0FF, $F0F, $880, $00F, $F44, $4F4, $088, $808, $880, $888, $A0A, $0AA, $AA0, $333, $FC8, $8FC 
	 
level4InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	;nop
	move.w  (a4),d2        ; Read VHPOSR
	andi    #$7,d2
	asl.b   #$1,d2
	move.w  RGB2(pc,d2),$DFF180

	move.l  #$DFF182,a7   ; Redirect stack pointer to color registers
		                  ; Causes level5InterruptHandler to write PC_LO into DFF180
	move    #$F,SR        ; Restore SR manually  
	move.w  #$000,$DFF180
	bra 	mainLoop      ; Exit IRQ handler manually

RGB2: 
	DC.W    $F00, $0F0, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $FFF, $400 
	DC.W    $0FF, $F0F, $880, $00F, $F44, $4F4, $088, $808, $880, $888, $A0A, $0AA, $AA0, $333, $FC8, $8FC 

level5InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	nop
	nop
	move.w  (a4),d2        ; Read VHPOSR
	andi    #$7,d2
	asl.b   #$1,d2
	move.w  RGB2(pc,d2),$DFF180

	move.l  bitplanes(pc),a7   ; Redirect stack pointer
		                  ; Causes level1InterruptHandler to write in unused (bitplane) area
	move    #$F,SR        ; Restore SR manually  
	move.w  #$000,$DFF180
	bra 	mainLoop      ; Exit IRQ handler manually
		  
level6InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	;move.w  #$000,$DFF180
	;move.w  #$000,$DFF182
	;move.w  #$000,$DFF184
	;move.w  #$000,$DFF186
	;rte

copper:

	;include	"image-copper-list-cropped.s"
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPLCON0,(4<<12)|$200 ; Enable 4 bitplanes to block every second bus cycle by bitplane DMA

	dc.w	INTENA,$E89C         ; Enable interrupts
	dc.w 	INTREQ,$8004         ; Level 1 interrupt (Reset bitplane pointers)
	; dc.w	COLOR00, $FF3

	dc.w    $3F39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00       ; Draw reference lines
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w    $4139, $FFFE         ; Wait
	dc.w 	INTREQ,$8008         ; Level 2 interrupt (Sync CPU with bitplane DMA disabled)

	dc.w    DMACON,$8100         ; Enable bitplane DMA (to finalize CPU sync)

	; dc.w    $4339, $FFFE         ; Wait
	; dc.w 	INTREQ,$8008         ; Level 2 interrupt (Sync CPU again with bitplane DMA enabled)

	dc.w    $4539, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w    $4739, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $4939, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8800         ; Level 5 interrupt

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	; dc.w	COLOR00, $888

	dc.w    DMACON,$0100         ; Disable bitplane DMA
	dc.w	INTENA,$3FFF         ; Disable interrupts

	dc.l	$fffffffe

bitplanes:
	; incbin	"out/image.bin"
	ds.b 61440,$00
	