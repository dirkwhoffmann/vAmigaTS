	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$00,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$01,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0123,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$012345,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$01234567,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0123456701234567,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$012300000123456701234567,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$012300008765432108765432,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 17+18   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$412300008765432108765432,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$812300008765432108765432,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$C12300008765432108765432,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$C99900008765432108765432,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $3F,$C9,$00,$00,  $E6,$95,$94,$BE  ; 3
    dc.b    $C4,$4D,$E1,$5B,  $00,$00,$00,$00  ; 4
    dc.b    $3F,$D0,$00,$00,  $DD,$93,$BC,$EF  ; 5
    dc.b    $50,$A2,$D6,$8E,  $00,$00,$00,$00  ; 6
    dc.b    $3F,$D7,$00,$00,  $AD,$BD,$8C,$C7  ; 7
    dc.b    $8D,$21,$3E,$61,  $00,$00,$00,$00  ; 8
    dc.b    $3F,$DE,$00,$00,  $87,$BD,$F8,$C5  ; 9
    dc.b    $15,$B1,$63,$BF,  $00,$00,$00,$00  ; 10
    dc.b    $3F,$F8,$00,$00,  $CA,$45,$7E,$5B  ; 11
    dc.b    $5B,$5A,$A3,$4C,  $00,$00,$00,$00  ; 12
    dc.b    $41,$91,$00,$00,  $98,$FD,$BD,$AB  ; 13
    dc.b    $4B,$D6,$B5,$98,  $00,$00,$00,$00  ; 14
    dc.b    $41,$97,$00,$00,  $A9,$B9,$86,$6F  ; 15
    dc.b    $7C,$75,$D4,$81,  $00,$00,$00,$00  ; 16
    dc.b    $3E,$66,$00,$00,  $94,$56,$73,$2F  ; 17
    dc.b    $7F,$7B,$56,$DA,  $00,$00,$00,$00  ; 18
    dc.b    $C1,$97,$00,$00,  $A9,$B9,$86,$6F  ; 19
    dc.b    $7C,$75,$D4,$81,  $00,$00,$00,$00  ; 20
    dc.b    $BE,$66,$00,$00,  $94,$56,$73,$2F  ; 21
    dc.b    $7F,$7B,$56,$DA,  $00,$00,$00,$00  ; 22
    dc.b    $B3,$08,$00,$00,  $93,$69,$FF,$DD  ; 23
    dc.b    $4B,$DA,$91,$A5,  $00,$00,$00,$00  ; 24
