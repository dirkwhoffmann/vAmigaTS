copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	;
	; 0 bitplanes
	; 

	dc.w    $5001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $5139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$0200 

	dc.w    $5339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $5939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $5B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $6343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $6543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 1 bitplane
	; 

	dc.w    $7001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $7139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$1200

	dc.w    $7339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $7939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $7B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $8343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $8543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 2 bitplanes
	; 

	dc.w    $9001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $9139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$2200

	dc.w    $9339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $9939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $9B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $A343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 3 bitplanes
	; 

	dc.w    $B001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $B139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$3200

	dc.w    $B339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $B939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $BB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $BD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $BF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $C343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $C543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $C743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 4 bitplanes
	; 

	dc.w    $D001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $D139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$4200

	dc.w    $D339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $D539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $D739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $D939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $DB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $DD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $DF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $E343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $E543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $E743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 5 bitplanes
	; 

	dc.w    $F001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $F139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$5200

	dc.w    $F339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $F539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $F739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $F939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $FB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $FD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $FF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $0343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $0543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $0743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $0943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $0A01, $FFFE
	dc.w    BPLCON0,$0200        ; 0 bitplanes

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00

stack: 
	ds.b 128,$00
