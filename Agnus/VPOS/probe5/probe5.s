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

    dc.w    $FF81,$FFFE
    dc.w    INTREQ, $8004       ; Level 1 interrupt
	ENDM
    
	include "../probe.i"

 info: 
    dc.b    'PROBE5', 0
    ALIGN 2
expected:
    dc.w    $FFBA,$FFC4,$FFCE,$FFD8,$FFE2,$0009,$0013,$001D
    dc.w    $0027,$0031,$003B,$0045,$004F,$0059,$0063,$006D
