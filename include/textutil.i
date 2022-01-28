	include hardware/custom.i
	include exec/types.i
    include exec/exec.i
	include graphics/text.i

_LVOAllocMem           equ     -198
_LVOOldOpenLibrary     equ     -408
_LVOCloseLibrary       equ     -414
_LVOOpenFont           equ     -72

; 
; Opens the topaz font and places the font data into a4
;
openfont:
    movem.l	d1-d7/a0-a3/a5-a6,-(a7) 

    move.l  $0004,a6          ; Execbase in a6

    ; Open graphics library
    lea     gfxname(pc),a1
    jsr     _LVOOldOpenLibrary(a6)
    tst.l   d0
    beq     error
    move.l  d0,a6             ; Gfxbase in a6

     ; Build textattr
    lea     topazname(pc),a1
    move.l  #$00080000,-(a7)  ; ta_YSize=8
    move.l  a1,-(a7)          ; ta_Name='topaz.font',0
    move.l  a7,a0

    ; Open Font
    jsr     _LVOOpenFont(a6)
    add.w   #8,a7
    move.l  d0,a0
    move.l  tf_CharData(a0),a4  ; store character data in a4

    movem.l	(a7)+,d1-d7/a0-a3/a5-a6
    rts

;
; Displays a single character or a (null-terminated) string
;
writechar:
    movem.l d1/a0/a1,-(a7)
    moveq   #0,d1
    move.b  d0,d1
    sub.b   #32,d1
    lea     (a4,d1.w),a1
    moveq   #7,d1
.l:     
	move.b  (a1),(a0)
    add.w   #320/8,a0
    add.w   #256-64,a1
    dbf     d1,.l
    movem.l (a7)+,d1/a0/a1
    addq.w  #1,a0
    rts

writestring:
    move.l  d0,-(a7)
.loop:
    move.b  (a1)+,d0
    beq     .done 
    bsr     writechar
    bra     .loop
.done: 
    move.l  (a7)+,d0
    rts

;
; Displays a byte, word, or long word in hex format
;
write4:
    and.b   #$f,d0
    add.b   #'0',d0
    cmp.b   #'9',d0
    ble.s   .wr
    add.b   #'A'-'0'-10,d0
.wr:   
	bsr.s   writechar
    rts

write8:
    ror.l  #4,d0
    bsr    write4
    rol.l  #4,d0 
    bsr    write4
    rts

write16:
    ror.l  #8,d0
    bsr    write8
    rol.l  #8,d0 
    bsr    write8
    rts

write32:
    swap   d0
    bsr    write16 
    swap   d0
    bsr    write16
    rts 

;
; Allocates Chip Ram memory
;
allocchip:
    movem.l	d1-d7/a0-a6,-(a7) 
    move.l	#MEMF_CHIP!MEMF_CLEAR,d1 
    move.l	$4,a6
    jsr	_LVOAllocMem(a6)
    tst.l   d0
    beq     error
    movem.l	(a7)+,d1-d7/a0-a6
    rts

gfxname:        
	dc.b 'graphics.library', 0
topazname:     
	dc.b 'topaz.font', 0

   ALIGN 2