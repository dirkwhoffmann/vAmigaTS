	include "../../fpureg.i"

WRITE   MACRO
        fmove.x FP0,(a2)
        fmove   FPCR,8(a2)
        fmove   FPSR,12(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #20,d1      ; Loop counter
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR

    ; Read constants
    fmovecr.x #$00,FP0
    WRITE

    fmovecr.x #$0B,FP0
    WRITE

    fmovecr.x #$0C,FP0
    WRITE
    fmovecr.x #$0D,FP0
    WRITE

    fmovecr.x #$0E,FP0
    WRITE

    fmovecr.x #$0F,FP0
    WRITE

    fmovecr.x #$30,FP0
    WRITE

    fmovecr.x #$31,FP0
    WRITE

    fmovecr.x #$32,FP0
    WRITE

    fmovecr.x #$33,FP0
    WRITE

    fmovecr.x #$34,FP0
    WRITE

    fmovecr.x #$35,FP0
    WRITE

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVECR1', 0
    even 

expected:
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 2
    dc.b    $3F,$FD,$00,$00,  $9A,$20,$9A,$84  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 4
    dc.b    $40,$00,$00,$00,  $AD,$F8,$54,$58  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 6
    dc.b    $3F,$FF,$00,$00,  $B8,$AA,$3B,$29  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 8
    dc.b    $3F,$FD,$00,$00,  $DE,$5B,$D8,$A9  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$08  ; 12
    dc.b    $3F,$FE,$00,$00,  $B1,$72,$17,$F7  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 14
    dc.b    $40,$00,$00,$00,  $93,$5D,$8D,$DD  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 16
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 18
    dc.b    $40,$02,$00,$00,  $A0,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 20
    dc.b    $40,$05,$00,$00,  $C8,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 22
    dc.b    $40,$0C,$00,$00,  $9C,$40,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 24
