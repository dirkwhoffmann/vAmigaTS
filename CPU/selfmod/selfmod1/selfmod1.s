	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
		
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

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8200,DMACON(a1)   ; DMAEN 

;
; Test section (self-modifying code)
;

	lea     mycolors,a2

test1: 
    moveq   #0,d0
	lea     .wcode,a0
	move.l  #$4E714E71,(a0)   ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0          
	lea	    color1+2,a0
	move.w  $0(a2,d0),(a0)

test2: 
    moveq   #0,d0
	lea     .wcode,a0
	subq    #$8,a0
	move.l  #$4E714E71,$8(a0)   ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0           
	lea	    color2+2,a0
	move.w  $0(a2,d0),(a0)

test3: 
    moveq   #0,d0
	moveq   #$4,d2
	lea     .wcode,a0
	subq    #$8,a0
	move.l  #$4E714E71,$4(a0,d2)   ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0           
	lea	    color3+2,a0
	move.w  $0(a2,d0),(a0)

test4: 
    moveq   #0,d0
	lea     .wcode,a0
	move.l  #$4E714E71,(a0)+   ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0    
	lea	    color4+2,a0
	move.w  $0(a2,d0),(a0)

test5: 
    moveq   #0,d0
	lea     .wcode,a0
	addq    #4,a0
	move.l  #$4E714E71,-(a0)   ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0      
	lea	    color4+2,a0
	move.w  $0(a2,d0),(a0)

test6: 
    moveq   #0,d0
	lea     .wcode,a3
	lea	    .movecmd,a0
	addq    #6,a0
	move.l  a3,(a0)
.movecmd:
	move.l  #$4E714E71,$FFFFFF  ; 2 NOPs
.wcode:
    addq    #2,d0            
    addq    #2,d0     
	lea	    color5+2,a0
	move.w  $0(a2,d0),(a0)

mainLoop:
	bra.s	mainLoop

mycolors:
    dc.w    $F33
	dc.w    $FF3
	dc.w    $33F
	dc.w    $0F0
	dc.w    $FFF
	dc.w    $888
	dc.w    $0FF
	dc.w    $F0F

copper:
	dc.w	BPLCON0,(0<<12)|$200 
	dc.w	$3001,$FFFE  ; WAIT
color1:
	dc.w	COLOR00, $F00
	dc.w	$4001,$FFFE  ; WAIT
color2:
	dc.w	COLOR00, $000
	dc.w	$5001,$FFFE  ; WAIT
color3:
	dc.w	COLOR00, $000
	dc.w	$6001,$FFFE  ; WAIT
color4:
	dc.w	COLOR00, $000
	dc.w	$7001,$FFFE  ; WAIT
color5:
	dc.w	COLOR00, $000
	dc.w	$8001,$FFFE  ; WAIT
color6:
	dc.w	COLOR00, $000
	dc.w	$9001,$FFFE  ; WAIT
color7:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe
