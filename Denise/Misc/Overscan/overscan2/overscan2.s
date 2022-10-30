        include hardware/custom.i
        include hardware/dmabits.i
        include graphics/gfxbase.i

custom=$dff000
ciaa=$bfe001

_LVOOldOpenLibrary=-408
_LVOCloseLibrary=-414

_LVOWaitTOF=-270
_LVOLoadView=-222

nwords=24

        section code,code

start:
        move.l  $4.w, a6
	lea	gfxname(pc), a1
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0, gfxbase

	move.l  d0, a6
	move.l	gb_ActiView(a6), oldview
	sub.l	a1, a1
	jsr	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)	
	jsr	_LVOWaitTOF(a6)

        lea     custom, a6
        move.w  #$7fff, d1
        move.w  intenar(a6), d0
        or.w    #$8000, d0
        move.w  d0, oldint
        move.w  d1, intena(a6)
        move.w  dmaconr(a6), d0
        or.w    #$8000, d0
        move.w  d0, olddma
        move.w  d1, dmacon(a6)

        bsr     main

	move.w	olddma, dmacon+custom
	move.w	oldint, intena+custom
	move.l	oldview, a1
	move.l	gfxbase, a6
	jsr	_LVOLoadView(a6)
	move.l	gb_copinit(a6), custom+cop1lc

	move.l	$4.w, a6
	move.l	gfxbase, a1
	jsr	_LVOCloseLibrary(a6)
        rts

gfxname:
	dc.b 'graphics.library', 0
	even

main:
        move.l  #gradient, d0
        move.l  #copperlist, a0
        rept 5
        move.w  d0, 6(a0)
        swap    d0
        move.w  d0, 2(a0)
        swap    d0
        lea     8(a0), a0
        add.l   #2*nwords, d0
        endr

        lea     colors(pc), a0
        lea     color(a6), a1
        move.w  #32-1, d0
.c:
        move.w  (a0)+, (a1)+
        dbf     d0, .c

        move.l  #copperlist, cop1lc(a6)
        clr.w   copjmp1(a6)
        move.w  #(5<<12)!(1<<9), bplcon0(a6)
        move.w  #0, bplcon1(a6)
        move.w  #$0024, bplcon2(a6)
        move.w  #0, bplcon3(a6)
        move.w  #$0011, bplcon4(a6)
        move.w  #0, fmode(a6)

        move.w  #$20, ddfstrt(a6)
        move.w  #$d8, ddfstop(a6)

        move.w  #$2c51, diwstrt(a6)
        move.w  #$2cd1, diwstop(a6)

        move.w  #-nwords*2, bpl1mod(a6)
        move.w  #-nwords*2, bpl2mod(a6)

        move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_COPPER!DMAF_RASTER, dmacon(a6)
.wait:
	btst	#6, ciaa
	bne     .wait
        rts

colors:
        ; Rainbow
        ;dc.w $F33, $F53, $F73, $FA3, $FC3, $FF3, $EF3, $BF3, $9F3, $7F3, $4F3, $3F3, $3F6, $3F8, $3FB, $3FD
        ;dc.w $3FF, $3DF, $3BF, $38F, $36F, $33F, $43F, $73F, $93F, $B3F, $E3F, $F3F, $F3C, $F3A, $F37, $F35

        ; Max contrast (http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.65.2790)
        dc.w $FFF, $00F, $F00, $0F0, $003, $F0B, $050, $FD0, $09F, $944, $0FB, $73C, $199, $FAF, $BC7, $F05
        dc.w $F84, $D0F, $210, $705, $769, $0A2, $CF0, $860, $FB9, $886, $A00, $1FF, $049, $D59, $9DF, $04F

        SECTION bss,bss
gfxbase: ds.l 1
oldview: ds.l 1
olddma:  ds.w 1
oldint:  ds.w 1

        SECTION data_c,data_c
copperlist:
        dc.w    bplpt+$00, $0000 ; 1
        dc.w    bplpt+$02, $0000
        dc.w    bplpt+$04, $0000 ; 2
        dc.w    bplpt+$06, $0000
        dc.w    bplpt+$08, $0000 ; 3
        dc.w    bplpt+$0a, $0000
        dc.w    bplpt+$0c, $0000 ; 4
        dc.w    bplpt+$0e, $0000
        dc.w    bplpt+$10, $0000 ; 5
        dc.w    bplpt+$12, $0000


        dc.w    $2905, $fffe
        dc.w    color, $000

        dc.w    $2a31, $fffe
        dc.w    color, $f00
        rept    21
        dc.w    color, $000
        dc.w    color, $0f0
        endr
        dc.w    color, $000
        dc.w    color, $00f
        dc.w    color, $000

        dc.w    $2b05, $fffe
        dc.w    color, $000

        dc.w    $2c05, $fffe
        dc.w    color, $fff

.n set 0
        rept 16
        dc.w    (($2c+16*.n)&$ff)<<8!$05,$fffe
        dc.w    bplcon1,.n<<4!.n
        ifeq .n-13
        dc.w    $ffdf,$fffe
        endc
.n set .n+1
        endr

        dc.l -2

gradient:
        rept nwords
        dc.w %0101010101010101
        endr
        rept nwords
        dc.w %0011001100110011
        endr
        rept nwords
        dc.w %0000111100001111
        endr
        rept nwords
        dc.w %0000000011111111
        endr
        rept nwords/2
        dc.w $0000, $ffff
        endr
