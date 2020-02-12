	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

entry:
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
		
	; Install interrupt handlers
	lea	irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR

	; Enable audio interrupts
	move.w	#$C780,INTENA(a1) 
 
;
; Main program
;

main: 
	; Setup 
	move.l #channel0,a4
	move.l #channel1,a5

	; Configure first channel
	move.w #(channel0end-channel0)/2,AUD0LEN(a1)
	move.w #32,AUD0VOL(a1)
	move.w #64*1016,AUD0PER(a1)

	; Configure second channel
	move.w #(channel1end-channel1)/2,AUD1LEN(a1)
	move.w #32,AUD1VOL(a1)
	move.w #1016,AUD1PER(a1)

	; Configure modulation
	move.w #$8001,ADKCON(a1)  ; Let channel 0 modulate volume of channel 1
	move.w #$8010,ADKCON(a1)  ; Let channel 0 modulate period of channel 1

	; Kick off IRQ based audio
	move.w #$0780,INTREQ(a1)
	move.w #0,AUD0DAT(a1)
	move.w #0,AUD1DAT(a1)

.loop:
	bra .loop

channel0: ; Modulation data
	;dc.b    0, 0, 0, 2, 0, 4, 0, 6, 0, 8, 0,10, 0,12, 0,14
	;dc.b    0,16, 0,18, 0,20, 0,22, 0,24, 0,26, 0,28, 0,30
	;dc.b    0,32, 0,34, 0,36, 0,38, 0,40, 0,42, 0,44, 0,46
	;dc.b    0,48, 0,50, 0,52, 0,54, 0,56, 0,58, 0,60, 0,62
	;dc.b    0,64, 0,62, 0,60, 0,58, 0,56, 0,54, 0,52, 0,50
	;dc.b    0,48, 0,46, 0,44, 0,42, 0,40, 0,38, 0,36, 0,34
	;dc.b    0,32, 0,30, 0,28, 0,26, 0,24, 0,22, 0,20, 0,18
	;dc.b    0,16, 0,14, 0,12, 0,10, 0, 8, 0, 6, 0, 4, 0, 2

	;dc.b     1,0,  2,0,  3,0,  4,0,  5,0,  6,0,  7,0,  8,0
	;dc.b     9,0, 10,0, 11,0, 12,0, 13,0, 14,0, 15,0, 16,0

	dc.b           1,0,  0,2,   2,0,  0,4,   3,0, 0,6,   4,0,  0,8,   5,0,  0,10,  6,0,  0,12,  7,0,  0,14,  8,0
	dc.b    0,16,  9,0,  0,18, 10,0,  0,20, 11,0, 0,22, 12,0,  0,24, 13,0,  0,26, 14,0,  0,28, 15,0,  0,30, 16,0
	dc.b    0,32,  1,0,  0,34,  2,0,  0,36,  3,0, 0,38,  4,0,  0,40,  5,0,  0,42,  6,0,  0,44,  7,0,  0,46,  8,0
	dc.b    0,48,  9,0,  0,50, 10,0,  0,52, 11,0, 0,54, 12,0,  0,56, 13,0,  0,58, 14,0,  0,60, 15,0,  0,62, 16,0

	dc.b    0,64,  1,0,  0,62,  2,0,  0,60,  3,0, 0,58,  4,0,  0,56,  5,0,  0,54,  6,0,  0,52,  7,0,  0,50,  8,0
	dc.b    0,48,  9,0,  0,46, 10,0,  0,44, 11,0, 0,42, 12,0,  0,40, 13,0,  0,38, 14,0,  0,36, 15,0,  0,34, 16,0
	dc.b    0,32,  1,0,  0,30,  2,0,  0,28,  3,0, 0,26,  4,0,  0,24,  5,0,  0,22,  6,0,  0,20,  7,0,  0,18,  8,0
	dc.b    0,16,  9,0,  0,14, 10,0,  0,12, 11,0, 0,10, 12,0,  0,8,  13,0,  0,6,  14,0,  0,4,  15,0,  0,2,  16,0

channel0end:


channel1: ; Sine wave
	dc.b    0,49
	dc.b    90,117
	dc.b    127,117
	dc.b    90,49
	dc.b    0,-49
	dc.b    -90,-117
	dc.b    -127,-117
	dc.b    -90,-49
channel1end:

irq4:
	btst    #7,(INTREQR+1)(a1)
	beq     .second

	move.w  #$FF0,COLOR00(a1)                
	move.w  #$0080,INTREQ(a1)  ; Acknowledge
       
	; Output next sample
	move.w  (a4)+,AUD0DAT(a1)
	cmpa.l  #channel0end,a4
	bne     .exit
	move.l  #channel0,a4
	bra     .exit

.second

	move.w  #$00F,COLOR00(a1)	                
	move.w  #$0100,INTREQ(a1) ; Acknowledge

	; Output next sample
	move.w  (a5)+,AUD1DAT(a1)
	cmpa.l  #channel1end,a5
	bne     .exit
	move.l  #channel1,a5
.exit:               
	move.w  #$000,COLOR00(a1)	 
	rte
