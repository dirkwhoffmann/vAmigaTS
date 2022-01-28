IRQ1 	MACRO
    move.w  VHPOSR(a1),d5
    lea     values,a2
    add.w   d4,a2
    move.w  d5,(a2)
    addi    #2,d4
    andi    #$1F,d4
    ENDM
    
COPPER 	MACRO
    ; 0
    dc.w    $4031,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $40B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 1
    dc.w    $4231,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $42B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 2
    dc.w    $4431,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $44B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 3
    dc.w    $4631,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $46B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 4
    dc.w    $4833,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $48B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 5
    dc.w    $4A33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4AB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 6
    dc.w    $4C33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4CB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 7
    dc.w    $4E33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $4EB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 8
    dc.w    $5035,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $50B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 9
    dc.w    $5235,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $52B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 10
    dc.w    $5435,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $54B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 11
    dc.w    $5635,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $56B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 12
    dc.w    $5837,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $58B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 13
    dc.w    $5A37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5AB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 14
    dc.w    $5C37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5CB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 15
    dc.w    $5E37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $5EB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze
	ENDM
    
	include "../probe.i"
 
 info: 
    dc.b    'PROBE2', 0
    ALIGN 2
expected:
    dc.w    $4067,$4269,$446F,$4671,$486B,$4A6D,$4C73,$4E75
    dc.w    $506B,$526D,$5473,$5675,$586D,$5A73,$5C75,$5E7B
