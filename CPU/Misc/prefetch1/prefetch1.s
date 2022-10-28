	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
		
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

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	move.w  COPJMP1(a6),d0

	; Enable DMA
	move.w	#$8080,DMACON(a6)   ; Copper DMA 	
	move.w	#$8200,DMACON(a6)   ; DMAEN 

	; Round 1
	jsr     performTests

	; Delay loop
	move.w   #$FFFF,d0
.loop1
	move.w   #$F,d1
.loop2
	dbra    d1,.loop2
	dbra    d0,.loop1


	; Round 2 
	; jsr     performTests

sleep:
	bra.s	sleep


performTests:

; $5280 : addq #1,d0
; $5480 : addq #2,d0
; $4E71 : nop

;
; Byte addressing
;

test1: 
    moveq   #0,d0
	lea     wcode1,a0
	move.b  #$54,d1
	move.b  d1,(a0)           ; Change to 5480 (addq #2,d0)
wcode1:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color1,a0
	jsr     setColor 

test2: 
    moveq   #0,d0
	lea     wcode2,a0
	lea     value54,a1
	move.b  (a1),(a0)         ; Change to 5480 (addq #2,d0)
wcode2:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color2,a0
	jsr     setColor 

test3: 
    moveq   #0,d0
	lea     wcode3,a0
	lea     value54,a1
	move.b  (a1)+,(a0)        ; Change to 5480 (addq #2,d0)
wcode3:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color3,a0
	jsr     setColor 

test4: 
    moveq   #0,d0
	lea     wcode4,a0
	lea     value54,a1
	addq    #1,a1             ; Compensate pre-decrement
	move.b  -(a1),(a0)        ; Change to 5480 (addq #2,d0)
wcode4:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color4,a0
	jsr     setColor 

test5: 
    moveq   #0,d0
	lea     wcode5,a0
	lea     value54,a1
	subq    #8,a1             ; Compensate displacement
	move.b  $8(a1),(a0)       ; Change to 5480 (addq #2,d0)
wcode5:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color5,a0
	jsr     setColor 

test6: 
    moveq   #0,d0
	moveq   #4,d1 
	lea     wcode6,a0
	lea     value54,a1
	subq    #8,a1             ; Compensate displacement and index
	move.b  $4(a1,d1),(a0)    ; Change to 5480 (addq #2,d0)
wcode6:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color6,a0
	jsr     setColor 

test7: 	     
   	moveq   #0,d0
	lea     value54,a0
	lea     cmdb,a1
	move.l  a0,$2(a1)         ; Change source address of next move command
	lea     wcode7,a0
cmdb:
	move.b  $FFFFFF,(a0)      ; Change to 5480 (addq #2,d0)
wcode7:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color7,a0
	jsr     setColor 

test8: 
    moveq   #0,d0
	lea     wcode8,a0
	move.b  #$54,(a0)         ; Change to 5480 (addq #2,d0)
wcode8:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color8,a0
	jsr     setColor 

;
; Word addressing
;

test11: 
    moveq   #0,d0
	lea     wcode11,a0
	move.w  #$4E71,d1
	move.w  d1,(a0)           ; Change to 4E71 (nop)
wcode11:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color11,a0
	jsr     setColor 

test12: 
    moveq   #0,d0
	lea     wcode12,a0
	lea     value4E71,a1
	move.w  (a1),(a0)         ; Change to 4E71 (nop)
wcode12:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color12,a0
	jsr     setColor 

test13: 
    moveq   #0,d0
	lea     wcode13,a0
	lea     value4E71,a1
	move.w  (a1)+,(a0)        ; Change to 4E71 (nop)
wcode13:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color13,a0
	jsr     setColor 

test14: 
    moveq   #0,d0
	lea     wcode14,a0
	lea     value4E71,a1
	addq    #2,a1             ; Compensate pre-decrement
	move.w  -(a1),(a0)        ; Change 4E71 (nop)
wcode14:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color14,a0
	jsr     setColor 

test15: 
    moveq   #0,d0
	lea     wcode15,a0
	lea     value4E71,a1
	subq    #8,a1             ; Compensate displacement
	move.w  $8(a1),(a0)       ; Change 4E71 (nop)
wcode15:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color15,a0
	jsr     setColor 

test16: 
    moveq   #0,d0
	moveq   #4,d1 
	lea     wcode16,a0
	lea     value4E71,a1
	subq    #8,a1             ; Compensate displacement and index
	move.w  $4(a1,d1),(a0)    ; Change 4E71 (nop)
wcode16:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color16,a0
	jsr     setColor 

test17: 	     
    moveq   #0,d0
	lea     value4E71,a0
	lea     cmdw,a1
	move.l  a0,$2(a1)         ; Change source address of next move command
	lea     wcode17,a0
cmdw:
	move.w  $FFFFFF,(a0)      ; Change to 4E71 (nop)
wcode17:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color17,a0
	jsr     setColor 

test18: 
    moveq   #0,d0
	lea     wcode18,a0
	move.w  #$4E71,(a0)       ; Change to 4E71 (nop)
wcode18:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color18,a0
	jsr     setColor 

;
; Long addressing
;

test21: 
    moveq   #0,d0
	lea     wcode21,a0
	move.l  #$4E71,d1
	move.l  d1,(a0)           ; Change to 4E71 (nop)
wcode21:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color21,a0
	jsr     setColor 

test22: 
    moveq   #0,d0
	lea     wcode22,a0
	lea     value4E71,a1
	move.l  (a1),(a0)         ; Change to 4E71 (nop)
wcode22:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color22,a0
	jsr     setColor 

test23: 
    moveq   #0,d0
	lea     wcode23,a0
	lea     value4E71,a1
	move.l  (a1)+,(a0)        ; Change to 4E71 (nop)
wcode23:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color23,a0
	jsr     setColor 

test24: 
    moveq   #0,d0
	lea     wcode24,a0
	lea     value4E71,a1
	addq    #4,a1             ; Compensate pre-decrement
	move.l  -(a1),(a0)        ; Change 4E71 (nop)
wcode24:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color24,a0
	jsr     setColor 

test25: 
    moveq   #0,d0
	lea     wcode25,a0
	lea     value4E71,a1
	subq    #8,a1             ; Compensate displacement
	move.l  $8(a1),(a0)       ; Change 4E71 (nop)
wcode25:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color25,a0
	jsr     setColor 

test26: 
    moveq   #0,d0
	moveq   #4,d1 
	lea     wcode26,a0
	lea     value4E71,a1
	subq    #8,a1             ; Compensate displacement and index
	move.l  $4(a1,d1),(a0)    ; Change 4E71 (nop)
wcode26:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color26,a0
	jsr     setColor 

test27: 	     
    moveq   #0,d0
	lea     value4E71,a0
	lea     cmdl,a1
	move.l  a0,$2(a1)         ; Change source address of next move command
	lea     wcode27,a0
cmdl:
	move.l  $FFFFFF,(a0)      ; Change to 4E71 (nop)
wcode27:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color27,a0
	jsr     setColor 

test28: 
    moveq   #0,d0
	lea     wcode28,a0
	move.l  #$4E714E71,(a0)   ; Change to 4E714E71 (2 x nop)
wcode28:
    addq    #1,d0             ; Opcode 5280  
    addq    #1,d0             ; Opcode 5280
	lea	    color28,a0
	jsr     setColor 

    rts

setColor:                    ; a0 = target address, d0 = color number
	lea     mycolors,a2
	addq    #2,a0            ; Move to next word
	lsl     #1,d0            ; Multiply d0 by 2 
	move.w  $0(a2,d0),(a0)   ; Assign color from color array 
	rts
    
mycolors:
    dc.w    $3F3
	dc.w    $FF3
	dc.w    $F33
	dc.w    $3F3
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
