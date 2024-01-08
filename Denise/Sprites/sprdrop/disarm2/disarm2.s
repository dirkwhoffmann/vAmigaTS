	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "../../../../include/ministartup.i"
		
; Constants
LVL3_INT_VECTOR		equ $6c
PAYLOAD             equ $0038
	
MAIN:

	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	lea bitplanes(pc),a0 
	; move.w #51201,d0
	move.w #6400,d0
.loop:
	move.w #$AAAA,(a0)+
	move.w #$AAAA,(a0)+
	move.w #$AAAA,(a0)+
	move.w #$AAAA,(a0)+
	dbra d0,.loop

	; Setup colors
	move.w #$000,COLOR00(a1)
	move.w #$FF0,COLOR01(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8020,DMACON(a1)   ; Sprite DMA 
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w  #$C020,INTENA(a1)
	
.mainLoop:
	bra.b	.mainLoop

irq3:

	movem.l	d0-a6,-(sp)
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge

	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL2PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL3PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL4PTH(a1),a3
	move.l	a2,(a3)

	; Sprite pointers
	lea     sprite0(pc),a2
	lea     SPR0PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite1(pc),a2
	lea     SPR1PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite2(pc),a2
	lea     SPR2PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite3(pc),a2
	lea     SPR3PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite4(pc),a2
	lea     SPR4PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite5(pc),a2
	lea     SPR5PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite6(pc),a2
	lea     SPR6PTH(a1),a3
	move.l	a2,(a3)

	lea     sprite7(pc),a2
	lea     SPR7PTH(a1),a3
	move.l	a2,(a3)

	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON1,$00
	dc.w    DDFSTRT,$0038
	dc.w	DDFSTOP,$00B0
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,$00 
	dc.w	BPL2MOD,$00
 
	DC.W    COLOR17,$0FF6 
	DC.W    COLOR18,$0444 
	DC.W    COLOR19,$0F00 
	DC.W    COLOR21,$06F6 
	DC.W    COLOR22,$0444 
	DC.W    COLOR23,$0F00 
	DC.W    COLOR25,$0FF0 
	DC.W    COLOR26,$0444 
	DC.W    COLOR27,$0F00 
	DC.W    COLOR29,$0CCC 
	DC.W    COLOR30,$0444 
	DC.W    COLOR31,$0F00 

	dc.w	BPLCON0,(2<<12)|$200 ; 2 bitplanes, lores mode

    ; 
	; Block 1
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$66F
	dc.w    COLOR03,$66F
	dc.w    COLOR15,$66F
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$471D,$FFFE  ; WAIT 
	dc.w    SPR0CTL,$4700 ; Disarm

 	; 
	; Block 2
	;

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    COLOR01,$B6F
	dc.w    COLOR03,$B6F
	dc.w    COLOR15,$B6F
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$571D,$FFFE  ; WAIT 
	dc.w    SPR1CTL,$5700 ; Disarm
	dc.w	$671D,$FFFE  ; WAIT 
	dc.w    SPR2CTL,$6700 ; Disarm

	; 
	; Block 3
	;

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    COLOR01,$F6F
	dc.w    COLOR03,$F6F
	dc.w    COLOR15,$F6F
	dc.w	$70D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$771D,$FFFE  ; WAIT 
	dc.w    SPR3CTL,$7700 ; Disarm
	dc.w	$871D,$FFFE  ; WAIT 
	dc.w    SPR4CTL,$8700 ; Disarm
  
	; 
	; Block 4
	;

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    COLOR01,$F6B
	dc.w    COLOR03,$F6B
	dc.w    COLOR15,$F6B
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$971D,$FFFE  ; WAIT 
	dc.w    SPR5CTL,$9700 ; Disarm
	dc.w	$A71D,$FFFE  ; WAIT 
	dc.w    SPR6CTL,$A700 ; Disarm

    ; 
	; Block 5
	;

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    COLOR01,$66F
	dc.w    COLOR03,$66F
	dc.w    COLOR15,$66F
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $B000
	dc.w	$B71D,$FFFE  ; WAIT 
	dc.w    SPR7CTL,$B700 ; Disarm

 	; 
	; Block 6
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    COLOR01,$B6F
	dc.w    COLOR03,$B6F
	dc.w    COLOR15,$B6F
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $D000
	dc.w	$D71D,$FFFE  ; WAIT 
	dc.w    SPR5CTL,$D700 ; Disarm

	dc.w    $F001,$FFFE  
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.l	$fffffffe

dummy:
	        DC.W    $0000,$0000 ; 0        
sprite0:	DC.W    $3040,$4700 ;VSTART, HSTART, VSTOP
sprite1:	DC.W    $4050,$5700 ;VSTART, HSTART, VSTOP
sprite2:	DC.W    $5060,$6700 ;VSTART, HSTART, VSTOP
sprite3:	DC.W    $6070,$7700 ;VSTART, HSTART, VSTOP
sprite4:	DC.W    $7080,$8700 ;VSTART, HSTART, VSTOP
sprite5:	DC.W    $8090,$9700 ;VSTART, HSTART, VSTOP
sprite6:	DC.W    $90A0,$A700 ;VSTART, HSTART, VSTOP
sprite7:	DC.W    $A0B0,$B700 ;VSTART, HSTART, VSTOP
			; 1
	        DC.W    $03C0,$0000 ; 0
	        DC.W    $0FF0,$0000 ; 1
	        DC.W    $1C78,$0380 ; 2
	        DC.W    $3DFC,$0380 ; 3
	        DC.W    $7DFE,$0380 ; 4
	        DC.W    $7FF8,$0000 ; 5
	        DC.W    $FFE0,$0000 ; 6
	        DC.W    $FF00,$0000 ; 7
	        DC.W    $FF00,$0000 ; 8
	        DC.W    $FFE0,$0000 ; 9
	        DC.W    $7FF8,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $3FFC,$0000 ; 13
	        DC.W    $1FF8,$0000 ; 14
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15

sprite0b:	DC.W    $6840,$7F00 ;VSTART, HSTART, VSTOP
sprite1b:	DC.W    $7850,$8F00 ;VSTART, HSTART, VSTOP
sprite2b:	DC.W    $8860,$9F00 ;VSTART, HSTART, VSTOP
sprite3b:	DC.W    $9870,$AF00 ;VSTART, HSTART, VSTOP
sprite4b:	DC.W    $A880,$BF00 ;VSTART, HSTART, VSTOP
sprite5b:	DC.W    $B890,$CF00 ;VSTART, HSTART, VSTOP
sprite6b:	DC.W    $C8A0,$DF00 ;VSTART, HSTART, VSTOP
sprite7b:	DC.W    $D8B0,$EF00 ;VSTART, HSTART, VSTOP

			; 2
	        DC.W    $03C0,$0000 ; 0
	        DC.W    $0FF0,$0000 ; 1
	        DC.W    $1C78,$0380 ; 2
	        DC.W    $3DFC,$0380 ; 3
	        DC.W    $7DFE,$0380 ; 4
	        DC.W    $7FF8,$0000 ; 5
	        DC.W    $FFE0,$0000 ; 6
	        DC.W    $FF00,$0000 ; 7
	        DC.W    $FF00,$0000 ; 8
	        DC.W    $FFE0,$0000 ; 9
	        DC.W    $7FF8,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $3FFC,$0000 ; 13
	        DC.W    $1FF8,$0000 ; 14
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15

	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data
	        DC.W    $0000,$0000 ; End of sprite data

bitplanes:
	ds.b    51201
	