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

    dc.w    $FF85,$FFFE
    dc.w    INTREQ, $8004       ; Level 1 interrupt
	ENDM
    
	include "../probe.i"

 info: 
    dc.b    'PROBE7', 0
    ALIGN 2
expected:
    dc.w    $FFBE,$FFC8,$FFD2,$FFDC,$0003,$000D,$0017,$0021
    dc.w    $002B,$0035,$003F,$0049,$0053,$005D,$0067,$0071
