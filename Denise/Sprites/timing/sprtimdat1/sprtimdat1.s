OFFSET              equ $00

WRITE MACRO
	dc.w 	\1,$FFFE
	dc.w    \2,$FFFF
	ENDM 

WRITEBLOCK MACRO
	WRITE   \1+$0000,\2
	WRITE   \1+$0402,\2
	WRITE   \1+$0804,\2
	WRITE   \1+$0C06,\2
	ENDM 

PAYLOAD	MACRO
	WRITEBLOCK	$3F7D,SPR0DATA
	WRITEBLOCK	$4F7D,SPR1DATA
	WRITEBLOCK	$5F7D,SPR2DATA
	WRITEBLOCK	$6F7D,SPR3DATA
	WRITEBLOCK	$7F7D,SPR4DATA
	WRITEBLOCK	$8F7D,SPR5DATA
	WRITEBLOCK	$9F7D,SPR6DATA
	WRITEBLOCK	$AF7D,SPR7DATA
	ENDM

	include "../sprtim.i"
