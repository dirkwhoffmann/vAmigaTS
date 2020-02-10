	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
CIAA_PRA            equ $BFE001	
CIAA_PRB            equ $BFE101
CIAA_DDRA           equ $BFE201
CIAA_DDRB           equ $BFE301
CIAA_TALO           equ $BFE401
CIAA_TAHI           equ $BFE501
CIAA_TBLO           equ $BFE601
CIAA_TBHI           equ $BFE701
CIAA_TODLO          equ $BFE801
CIAA_TODMID         equ $BFE901
CIAA_TODHI          equ $BFEA01
CIAA_SDR            equ $BFEC01
CIAA_ICR            equ $BFED01
CIAA_CRA            equ $BFEE01
CIAA_CRB            equ $BFEF01

CIAB_PRA            equ $BFD000	
CIAB_PRB            equ $BFD100
CIAB_DDRA           equ $BFD200
CIAB_DDRB           equ $BFD300
CIAB_TALO           equ $BFD400
CIAB_TAHI           equ $BFD500
CIAB_TBLO           equ $BFD600
CIAB_TBHI           equ $BFD700
CIAB_TODLO          equ $BFD800
CIAB_TODMID         equ $BFD900
CIAB_TODHI          equ $BFDA00
CIAB_SDR            equ $BFDC00
CIAB_ICR            equ $BFDD00
CIAB_CRA            equ $BFDE00
CIAB_CRB            equ $BFDF00

;
; Main
;

entry:
	; Load OCS base address into a1
	lea CUSTOM,a1
	
	moveq #0,d4

    ; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,CIAB_ICR     ; CIA B
	move.b  #$7F,CIAA_ICR     ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)
		
	; Install interrupt handlers
	lea	    irq1(pc),a2
 	move.l  a2,LVL1_INT_VECTOR
	lea	    irq2(pc),a2
 	move.l  a2,LVL2_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l  a2,LVL3_INT_VECTOR
	lea	    irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	    irq5(pc),a2
 	move.l	a2,LVL5_INT_VECTOR
	lea	    irq6(pc),a2
 	move.l	a2,LVL6_INT_VECTOR

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

  	; Configure CIAs
	move.b #$84,CIAB_ICR  ; Enable TOD interrupt

	; Enable all interrupts
	move.w  #$FFFF,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu            ; Sync CPU

	lea	(bit0+2)(pc),a0
	move.w #$000,(a0)
	lea	(bit1+2)(pc),a0
	move.w #$111,(a0)
	lea	(bit2+2)(pc),a0
	move.w #$222,(a0)
	lea	(bit3+2)(pc),a0
	move.w #$333,(a0)
	lea	(bit4+2)(pc),a0
	move.w #$444,(a0)
	lea	(bit5+2)(pc),a0
	move.w #$555,(a0)
	lea	(bit6+2)(pc),a0
	move.w #$666,(a0)
	lea	(bit7+2)(pc),a0
	move.w #$777,(a0)

	lea	(bit8+2)(pc),a0
	move.w #$888,(a0)
	lea	(bit9+2)(pc),a0
	move.w #$999,(a0)
	lea	(bit10+2)(pc),a0
	move.w #$AAA,(a0)
	lea	(bit11+2)(pc),a0
	move.w #$BBB,(a0)
	lea	(bit12+2)(pc),a0
	move.w #$CCC,(a0)
	lea	(bit13+2)(pc),a0
	move.w #$DDD,(a0)
	lea	(bit14+2)(pc),a0
	move.w #$EEE,(a0)
	lea	(bit15+2)(pc),a0
	move.w #$FFF,(a0)

	bra     main               ; Repeat

;
; IRQ handlers
;

irq1:
	btst    #1,(INTREQR+1)(a1)
	bne     irq1_dskblk
	btst    #2,(INTREQR+1)(a1)
	bne     irq1_soft

	move.w  #$0001,INTREQ(a1)   ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	lea	(bit0+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$01,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$00,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq1_dskblk:
	move.w  #$0002,INTREQ(a1)   ; Acknowledge
	move.w  #$FF0,COLOR00(a1)

	lea	(bit1+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$0F,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq1_soft:	
	move.w  #$0004,INTREQ(a1)   ; Acknowledge
	move.w  #$0F0,COLOR00(a1)

	lea	(bit2+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$1F,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.b  CIAA_ICR,d0         ; Clear ICR
	move.w	#$0008,INTREQ(a1)   ; Acknowledge 

	move.w #$FF0,(a6)
	rte

irq3:
	btst    #5,(INTREQR+1)(a1)
	bne     irq3_vertb
	btst    #6,(INTREQR+1)(a1)
	bne     irq3_blit

	move.w  #$0010,INTREQ(a1)   ; Acknowledge
	move.w  #$00F,COLOR00(a1)

	lea	(bit3+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$10,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$1F,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq3_vertb:

	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$00F,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq3_blit:

	move.w  #$0040,INTREQ(a1)   ; Acknowledge
	move.w  #$0FF,COLOR00(a1)

	lea	(bit4+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$FF,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq4:
	btst    #0,INTREQR(a1)
	bne     irq4_aud1
	btst    #1,INTREQR(a1)
	bne     irq4_aud2
	btst    #2,INTREQR(a1)
	bne     irq4_aud3
        
	move.w  #$0080,INTREQ(a1)   ; Acknowledge
	move.w  #$F0F,COLOR00(a1)

	lea	(bit5+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$F0,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$FF,CIAB_TODMID
	move.b  #$00,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq4_aud1:

	move.w  #$0100,INTREQ(a1)   ; Acknowledge
	move.w  #$800,COLOR00(a1)

	lea	(bit6+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$20,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$2F,CIAB_TODMID
	move.b  #$20,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq4_aud2:

	move.w  #$0200,INTREQ(a1)   ; Acknowledge
	move.w  #$880,COLOR00(a1)

	lea	(bit7+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$20,CIAB_TODMID
	move.b  #$20,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$2F,CIAB_TODMID
	move.b  #$20,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq4_aud3:

	move.w  #$0400,INTREQ(a1)   ; Acknowledge
	move.w  #$080,COLOR00(a1)

	lea	(bit8+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$F0,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$AF,CIAB_TODMID
	move.b  #$F0,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq5:

	btst    #4,INTREQR(a1)
	bne     irq5_dsksyn
        
	move.w  #$0800,INTREQ(a1)   ; Acknowledge
	move.w  #$008,COLOR00(a1)

	lea	(bit9+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$A0,CIAB_TODMID
	move.b  #$F0,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$AF,CIAB_TODMID
	move.b  #$F0,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq5_dsksyn:

	move.w  #$1000,INTREQ(a1)   ; Acknowledge
	move.w  #$088,COLOR00(a1)

	lea	(bit10+2)(pc),a6
	move.b  #$80,CIAB_CRB       ; Write alarm
	move.b  #$00,CIAB_TODMID
	move.b  #$FF,CIAB_TODHI
	move.b  #$00,CIAB_TODLO

	move.b  #$00,CIAB_CRB       ; Write tod
	move.b  #$CF,CIAB_TODMID
	move.b  #$FF,CIAB_TODHI
	move.b  #$FF,CIAB_TODLO

	move.w  #$000,COLOR00(a1)
	rte

irq6:
	move.b  CIAB_ICR,d0         ; Clear ICR
	move.w	#$2000,INTREQ(a1)   ; Acknowledge 

	move.w #$0FF,(a6)
	rte

synccpu:
	lea     VHPOSR(a1),a3       ; VHPOSR     
	
	; Wait until we have reached the middle of a frame
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

;
; Copper
;

copper:

	;
	; Compute result
	;
	
	dc.w    $6001,$FFFE 
	dc.w    INTREQ,$8001 ; Level 1 IRQ

	dc.w    $6401,$FFFE 
	dc.w    INTREQ,$8002 ; Level 1 IRQ

	dc.w    $6801,$FFFE 
	dc.w    INTREQ,$8004 ; Level 1 IRQ

	dc.w    $6C01,$FFFE 
	dc.w    INTREQ,$8010 ; Level 3 IRQ

	dc.w    $7001,$FFFE 
	dc.w    INTREQ,$8040 ; Level 3 IRQ

	dc.w    $7401,$FFFE 
	dc.w    INTREQ,$8080 ; Level 4 IRQ

	dc.w    $7801,$FFFE 
	dc.w    INTREQ,$8100 ; Level 4 IRQ

	dc.w    $7C01,$FFFE 
	dc.w    INTREQ,$8200 ; Level 4 IRQ

	dc.w    $8001,$FFFE 
	dc.w    INTREQ,$8400 ; Level 4 IRQ

	dc.w    $8401,$FFFE 
	dc.w    INTREQ,$8800 ; Level 5 IRQ

	dc.w    $8801,$FFFE 
	dc.w    INTREQ,$9000 ; Level 5 IRQ

	;
	; Visualize
	;
	
	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B8D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$C001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C0D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$C801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C8D9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D0D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$D801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D8D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$E001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E0D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E8D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$F001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F0D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$F801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F8D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$0801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$08D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$1001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$10D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.l    $fffffffe	
	
	