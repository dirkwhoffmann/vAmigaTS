IRQ1 	MACRO
    lea     values,a2
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VPOSR(a1),d5
    move.w  d5,(a2)+
    ENDM

COPPER 	MACRO

    dc.w    $1001,$FFFE
    dc.w    INTREQ,$8008        ; Level 2 interrupt

    dc.w    $4001,$FFFE 
    dc.w    BPLCON0,$2200

    dc.w    $FF7F,$FFFE
    dc.w    INTREQ, $8004       ; Level 1 interrupt
	ENDM
    
	include "../vprobe.i"

 info: 
    dc.b    'VPROBE1', 0
    ALIGN 2
expected:
    dc.w    $8000,$8000,$8000,$8000,$8000,$8001,$8001,$8001
    dc.w    $8001,$8001,$8001,$8001,$8001,$8001,$8001,$8001
