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
    dc.w    $4081,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
	ENDM
    
	include "../probe.i"

 info: 
    dc.b    'PROBE3', 0
    ALIGN 2
expected:
    dc.w    $40B7,$40C1,$40CB,$40D5,$40DF,$4107,$4111,$411B
    dc.w    $4125,$412F,$4139,$4143,$414D,$4157,$4161,$416B
