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

    ; 0
    dc.w    $E031,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E0B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 1
    dc.w    $E231,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E2B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 2
    dc.w    $E431,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E4B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 3
    dc.w    $E631,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E6B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 4
    dc.w    $E833,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $E8B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 5
    dc.w    $EA33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $EAB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 6
    dc.w    $EC33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $ECB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 7
    dc.w    $EE33,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $EEB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 8
    dc.w    $F035,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F0B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 9
    dc.w    $F235,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F2B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 10
    dc.w    $F435,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F4B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 11
    dc.w    $F635,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F6B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 12
    dc.w    $F837,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $F8B1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 13
    dc.w    $FA37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FAB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 14
    dc.w    $FC37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FCB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze

    ; 15
    dc.w    $FE37,$FFFE
    dc.w    BPLCON0,$2202        ; Freeze
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    $1FE,$0              ; NOP 
    dc.w    INTREQ, $8004        ; Level 1 interrupt
    dc.w    $FEB1,$FFFE
    dc.w    BPLCON0,$2200        ; Unfreeze
	ENDM
    
	include "../probe.i"
 
 info: 
    dc.b    'ERSY1', 0
    ALIGN 2
expected:
    dc.w    $E06F,$E271,$E477,$E679,$E873,$EA75,$EC7B,$EE7D
    dc.w    $F073,$F275,$F476,$F67A,$F870,$FA76,$FC7A,$FE7C