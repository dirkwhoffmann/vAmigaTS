;IRQ1 	MACRO
;    move.w  VHPOSR(a1),d5
;    lea     values,a2
;    add.w   d4,a2
;    move.w  d5,(a2)
;    addi    #2,d4
;   andi    #$1F,d4
;    ENDM

IRQ1 	MACRO
    move.w  VHPOSR(a1),d5
    lea     values,a2
    move.w  counter,d4
    add.w   d4,a2
    move.w  d5,(a2)
    addi    #2,d4
    andi    #$1F,d4
    move.w  d4,counter
    ENDM

COPPER 	MACRO

    dc.w    $0401,$FFFE 
    dc.w    INTREQ, $8008        ; Level 2 interrupt

    dc.w    $3801,$FFFE
    dc.w    BPLCON0,$2200

    dc.w    $E051,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E253,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E455,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E657,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E859,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $EA5B,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $EC5D,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $EE5F,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F061,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F263,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F465,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F667,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F869,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FA6B,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FC6D,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FE6F,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	ENDM
    
	include "../probe.i"
 
 info: 
    dc.b    'PROBE1', 0
    ALIGN 2
expected:
    dc.w    $E08B,$E28D,$E48F,$E691,$E891,$EA97,$EC97,$EE99
    dc.w    $F09B,$F29D,$F49C,$F69C,$F8A1,$FAA2,$FCA2,$FEA6
