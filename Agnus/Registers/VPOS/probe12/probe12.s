IRQ1 	MACRO
    lea     values,a2
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    ENDM

COPPER 	MACRO

    dc.w    $1001,$FFFE
    dc.w    INTREQ,$8008        ; Level 2 interrupt

    dc.w    $4001,$FFFE 
    dc.w    BPLCON0,$2200

	dc.w    $ffdf,$fffe         ; Cross vertical boundary

    dc.w    $1001,$FFFE
    dc.w    VPOSW,$0001         ; Make a short frame

    dc.w    $3783,$FFFE
    dc.w    INTREQ, $8004       ; Level 1 interrupt
	ENDM
    
	include "../probe.i"

 info: 
    dc.b    'PROBE12', 0
    ALIGN 2
expected:
    dc.w    $37BC,$37C6,$37D0,$37DA,$3701,$0011,$001B,$0025
    dc.w    $002F,$0039,$0043,$004D,$0057,$0061,$006B,$0075
