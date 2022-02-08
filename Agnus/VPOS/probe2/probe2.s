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

    dc.w    $E881,$FFFE
    dc.w    INTREQ, $8004       ; Level 1 interrupt
	ENDM
    
	include "../probe.i"

 info: 
    dc.b    'PROBE2', 0
    ALIGN 2
expected:
    dc.w    $E8BE,$E8C8,$E8D2,$E8DC,$E903,$E90D,$E917,$E921
    dc.w    $E92B,$E935,$E93F,$E949,$E953,$E95D,$E967,$E971
