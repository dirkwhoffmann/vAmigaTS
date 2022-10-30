	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
		
LVL1_INT_VECTOR		equ $64

MAIN:

	; Load OCS base address
	lea CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a6)
	move.w  #$7FFF,DMACON(a6)
	move.w  #$200,BPLCON0(a6)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	    irq1(pc),a2
 	move.l  a2,LVL1_INT_VECTOR

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	move.w  COPJMP1(a6),d0

	; Enable DMA
	move.w	#$8080,DMACON(a6)   ; Copper DMA 	
	move.w	#$8200,DMACON(a6)   ; DMAEN 

	; Enable interrupts
	move.w  #$C004,INTENA(a6)

    ; Perform tests
	jsr performTests

.done:
	bra .done

;
; Interrupt handler
;

irq1: 
	jsr     setColor 
	move.w  #$0004,INTREQ(a6)   ; Acknowledge
	rte
;
; Perform tests
;
	
performTests:

test1: 
	lea	    color1,a0
    moveq   #0,d0
	move.w  #$8004,INTREQ(a6)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test2: 
	lea	    color2,a0
    moveq   #0,d0
	lea     $DFF09C,a3
	move.w  #$8004,(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test3: 
	lea	    color3,a0
    moveq   #0,d0
	lea     $DFF09C,a3
	move.w  #$8004,(a3)+
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test4: 
	lea	    color4,a0
    moveq   #0,d0
	lea     $DFF09E,a3
	move.w  #$8004,-(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test5: 
	lea	    color5,a0
    moveq   #0,d0
	lea     $DFF09A,a3
	move.w  #$8004,$2(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test6: 
	lea	    color6,a0
    moveq   #0,d0
	lea     $DFF09A,a3
	move.w  #$8004,$2(a3,d0)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test7: 
	lea	    color7,a0
    moveq   #0,d0
	move.w  #$8004,$DFF09C
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

;
; Long writes
;

test11: 
	lea	    color11,a0
    moveq   #0,d0
	move.l  #$C0048004,INTENA(a6)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test12: 
	lea	    color12,a0
    moveq   #0,d0
	lea     $DFF09A,a3
	move.l  #$C0048004,(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test13: 
	lea	    color13,a0
    moveq   #0,d0
	lea     $DFF09A,a3
	move.l  #$C0048004,(a3)+
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test14: 
	lea	    color14,a0
    moveq   #0,d0
	lea     $DFF09E,a3
	move.l  #$C0048004,-(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test15: 
	lea	    color15,a0
    moveq   #0,d0
	lea     $DFF098,a3
	move.l  #$C0048004,$2(a3)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test16: 
	lea	    color16,a0
    moveq   #0,d0
	lea     $DFF098,a3
	move.l  #$C0048004,$2(a3,d0)
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

test17: 
	lea	    color17,a0
    moveq   #0,d0
	move.l  #$C0048004,$DFF09A
	moveq   #1,d0 
	moveq   #2,d0 
	moveq   #3,d0 

    rts

setColor:                    ; a0 = target address, d0 = color number
	lea     mycolors,a2
	addq    #2,a0            ; Move to next word
	lsl     #1,d0            ; Multiply d0 by 2 
	move.w  $0(a2,d0),(a0)   ; Assign color from color array 
	rts
    
mycolors:
    dc.w    $3F3
	dc.w    $F33
	dc.w    $FF3
	dc.w    $33F
	dc.w    $3FF
	dc.w    $F3F
	dc.w    $FFF
value54:
	dc.b    $54
	dc.b    $00
value5480:
	dc.w    $5480
	dc.w    $5480
value4E71:
	dc.w    $4E71
	dc.w    $4E71

copper:
	dc.w	BPLCON0,(0<<12)|$200 
	dc.w	$3001,$FFFE  ; WAIT
color1:
	dc.w	COLOR00, $444
	dc.w	$3401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$3801,$FFFE  ; WAIT
color2:
	dc.w	COLOR00, $444
	dc.w	$3C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$4001,$FFFE  ; WAIT
color3:
	dc.w	COLOR00, $444
	dc.w	$4401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$4801,$FFFE  ; WAIT
color4:
	dc.w	COLOR00, $444
	dc.w	$4C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$5001,$FFFE  ; WAIT
color5:
	dc.w	COLOR00, $444
	dc.w	$5401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$5801,$FFFE  ; WAIT
color6:
	dc.w	COLOR00, $444
	dc.w	$5C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$6001,$FFFE  ; WAIT
color7:
	dc.w	COLOR00, $444
	dc.w	$6401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$6801,$FFFE  ; WAIT
color8:
	dc.w	COLOR00, $444
	dc.w	$6C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$7001,$FFFE  ; WAIT

;
; Word tests
;

	dc.w	$8001,$FFFE  ; WAIT
color11:
	dc.w	COLOR00, $444
	dc.w	$8401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$8801,$FFFE  ; WAIT
color12:
	dc.w	COLOR00, $444
	dc.w	$8C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$9001,$FFFE  ; WAIT
color13:
	dc.w	COLOR00, $444
	dc.w	$9401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$9801,$FFFE  ; WAIT
color14:
	dc.w	COLOR00, $444
	dc.w	$9C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$A001,$FFFE  ; WAIT
color15:
	dc.w	COLOR00, $444
	dc.w	$A401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$A801,$FFFE  ; WAIT
color16:
	dc.w	COLOR00, $444
	dc.w	$AC01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$B001,$FFFE  ; WAIT
color17:
	dc.w	COLOR00, $444
	dc.w	$B401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$B801,$FFFE  ; WAIT
color18:
	dc.w	COLOR00, $444
	dc.w	$BC01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$C001,$FFFE  ; WAIT
	
;
; Long  tests
;

	dc.w	$D001,$FFFE  ; WAIT
color21:
	dc.w	COLOR00, $444
	dc.w	$D401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$D801,$FFFE  ; WAIT
color22:
	dc.w	COLOR00, $444
	dc.w	$DC01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$E001,$FFFE  ; WAIT
color23:
	dc.w	COLOR00, $444
	dc.w	$E401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$E801,$FFFE  ; WAIT
color24:
	dc.w	COLOR00, $444
	dc.w	$EC01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$F001,$FFFE  ; WAIT
color25:
	dc.w	COLOR00, $444
	dc.w	$F401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$F801,$FFFE  ; WAIT
color26:
	dc.w	COLOR00, $444
	dc.w	$FC01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$ffdf,$fffe          ; Cross vertical boundary
	dc.w	$0001,$FFFE  ; WAIT
color27:
	dc.w	COLOR00, $444
	dc.w	$0401,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$0801,$FFFE  ; WAIT
color28:
	dc.w	COLOR00, $444
	dc.w	$0C01,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w	$1001,$FFFE  ; WAIT


	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe
