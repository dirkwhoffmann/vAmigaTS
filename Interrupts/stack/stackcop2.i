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
	; 6 bitplanes
	; 

	dc.w    $5001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $5139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$6200
	
	dc.w    $5319, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5519, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5719, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $5919, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $5B21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5D21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5F21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6121, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $6323, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $6523, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6723, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6923, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 6 bitplane
	; 

	dc.w    $7001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $7139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$6200

	dc.w    $7325, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7525, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7725, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $7925, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $7B27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7D27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7F27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8127, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $8329, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $8529, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8729, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8929, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 6 bitplanes
	; 

	dc.w    $9001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $9139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$6200

	dc.w    $932B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $952B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $972B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $992B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $9B2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9D2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9F2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A12D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $A32F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A52F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A72F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A92F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 6 bitplanes
	; 

	dc.w    $B001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $B139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$6200

	dc.w    $B331, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B531, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B731, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $B931, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $BB33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $BD33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $BF33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C133, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $C335, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $C535, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $C735, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C935, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 6 bitplanes
	; 

	dc.w    $D001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $D139, $FFFE         ; WAIT
	RULER

	dc.w    BPLCON0,$6200

	dc.w    $D337, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $D537, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $D737, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $D937, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $DB39, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $DD39, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $DF39, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E139, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $E33B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $E53B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $E73B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E93B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 6 bitplanes
	; 

	dc.w    $F001, $FFFE
	dc.w    BPLCON0,$0200 
	dc.w    $F139, $FFFE         ; WAIT
	RULER
	
	dc.w    BPLCON0,$6200

	dc.w    $F33D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $F53D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $F73D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $F93D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $FB3F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $FD3F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $FF3F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $0341, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $0541, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $0741, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $0941, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $0A01, $FFFE
	dc.w    BPLCON0,$0200        ; 0 bitplanes



	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00

stack: 
	ds.b 128,$00
