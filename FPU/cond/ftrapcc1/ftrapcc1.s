	include "../../fpureg.i"

EXEC    MACRO
        moveq   #1,d2
        \1
        move.b  d2,(a2)+
        ENDM

TRP7_INT_VECTOR     equ $1C

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    ; Install trap handler
    lea     handler(pc),a3
    move.l  a3,TRP7_INT_VECTOR

    lea     values,a2 
    moveq   #0,d0       ; FPSR payload
    moveq   #11,d1      ; Loop counter (12 iterations)

    fmove.l #0,FPCR

.loop1:
    fmove.l d0,FPSR     ; Setup status register 

    EXEC    ftrapge
    EXEC    ftrapgl
    EXEC    ftrapgle
    EXEC    ftrapgt
    EXEC    ftraple  
    EXEC    ftraplt  
    EXEC    ftrapnge 
    EXEC    ftrapngl 
    EXEC    ftrapngle
    EXEC    ftrapngt 
    EXEC    ftrapnle 
    EXEC    ftrapnlt 
    EXEC    ftrapseq 
    EXEC    ftrapsne 
    EXEC    ftrapsf  
    EXEC    ftrapst  

    add.l   #$01000000,d0
    dbra    d1,.loop1

    movem.l (a7)+,d0-d3/a2/a3
    rte

handler:
    fsave   -(sp)       ; Save internal state
    move.b  (sp),d2     ; First byte of state frame
    beq     null        ; Branch if NULL frame
    clr.l   d2          ; Clear data register 
    move.b  1(sp),d2    ; Load state frame size
    bset    #3,(sp,d2)  ; Set bit 27 of BIU 

    moveq   #8,d2

null:
    frestore (sp)+      ; Restore state 
    rte

info: 
    dc.b    'FTRAPCC1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $08,$08,$08,$08,  $01,$01,$01,$01  ; 1
    dc.b    $01,$01,$08,$08,  $01,$08,$01,$08  ; 2
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$08  ; 3
    dc.b    $08,$08,$08,$08,  $01,$08,$01,$08  ; 4
    dc.b    $08,$08,$08,$08,  $01,$01,$01,$01  ; 5
    dc.b    $01,$01,$08,$08,  $01,$08,$01,$08  ; 6
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$08  ; 7
    dc.b    $08,$08,$08,$08,  $01,$08,$01,$08  ; 8
    dc.b    $08,$01,$08,$01,  $08,$01,$01,$08  ; 9
    dc.b    $01,$08,$01,$08,  $08,$01,$01,$08  ; 10
    dc.b    $08,$01,$08,$01,  $08,$01,$08,$08  ; 11
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$08  ; 12
    dc.b    $08,$01,$08,$01,  $08,$01,$01,$08  ; 13
    dc.b    $01,$08,$01,$08,  $08,$01,$01,$08  ; 14
    dc.b    $08,$01,$08,$01,  $08,$01,$08,$08  ; 15
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$08  ; 16
    dc.b    $01,$08,$08,$01,  $08,$08,$08,$01  ; 17
    dc.b    $01,$08,$01,$01,  $01,$08,$01,$08  ; 18
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$08  ; 19
    dc.b    $08,$08,$08,$08,  $01,$08,$01,$08  ; 20
    dc.b    $01,$08,$08,$01,  $08,$08,$08,$01  ; 21
    dc.b    $01,$08,$01,$01,  $01,$08,$01,$08  ; 22
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$08  ; 23
    dc.b    $08,$08,$08,$08,  $01,$08,$01,$08  ; 24
