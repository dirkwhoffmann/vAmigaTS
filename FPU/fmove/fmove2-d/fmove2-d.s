	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #11,d1      ; Loop counter (12 iterations)
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR
    add     #$10,d0

    ; Load a floating-point constant and write it into memory
    fmovecr #$00,FP0
    fneg    FP0
    fmove.d FP0,(a2)

    ; Also display some other register content
    fmove   FPCR,8(a2)
    fmove   FPSR,12(a2)

    add     #16,a2

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVE2-D', 0
    even 

expected:
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 1
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 2
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 3
    dc.b    $00,$00,$00,$10,  $08,$00,$02,$08  ; 4
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$19  ; 5
    dc.b    $00,$00,$00,$20,  $08,$00,$02,$08  ; 6
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 7
    dc.b    $00,$00,$00,$30,  $08,$00,$02,$08  ; 8
    dc.b    $C0,$09,$21,$FB,  $60,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$40,  $08,$00,$00,$08  ; 10
    dc.b    $C0,$09,$21,$FB,  $40,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$50,  $08,$00,$00,$08  ; 12
    dc.b    $C0,$09,$21,$FB,  $40,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$60,  $08,$00,$00,$08  ; 14
    dc.b    $C0,$09,$21,$FB,  $60,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$70,  $08,$00,$00,$08  ; 16
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 17
    dc.b    $00,$00,$00,$80,  $08,$00,$00,$08  ; 18
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 19
    dc.b    $00,$00,$00,$90,  $08,$00,$00,$08  ; 20
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$18  ; 21
    dc.b    $00,$00,$00,$A0,  $08,$00,$00,$08  ; 22
    dc.b    $C0,$09,$21,$FB,  $54,$44,$2D,$19  ; 23
    dc.b    $00,$00,$00,$B0,  $08,$00,$00,$08  ; 24
