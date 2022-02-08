IRQ1 	MACRO
    move.w  VHPOSR(a1),d5
    lea     values,a2
    add.w   d4,a2
    move.w  d5,(a2)
    addi    #2,d4
    andi    #$1F,d4
    ENDM
    
COPPER 	MACRO

    dc.w    $4051,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4253,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4455,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4657,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4859,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4A5B,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4C5D,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4E5F,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5061,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5263,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5465,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5667,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5869,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5A6B,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5C6D,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5E6F,$FFFE
    dc.w    INTREQ, $8004        ; Level 1 interrupt
	ENDM
    
	include "../probe.i"
 
 info: 
    dc.b    'PROBE1', 0
    ALIGN 2
expected:
    dc.w    $4083,$4285,$4487,$4689,$4889,$4A8F,$4C8F,$4E91
    dc.w    $5093,$5295,$5495,$569B,$589B,$5A9D,$5C9F,$5EA1
