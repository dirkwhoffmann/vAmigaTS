	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "../diw.i"

copper:

	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1

    ; First color block: Shrink the visible area
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cC1
	dc.w	$3801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c91 
	dc.w	DIWSTOP,$2cB1
	dc.w	$4001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA1 
	dc.w	DIWSTOP,$2cA1
	dc.w	$4801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cB1 
	dc.w	DIWSTOP,$2c91
	dc.w	$5001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	$5801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cD1 
	dc.w	DIWSTOP,$2c71

	; Second color block: Test DISTRT with horizontal values 0,1,2,3
	dc.w    $6F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $6FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c00
	dc.w	DIWSTOP,$2c71
	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
    dc.w    $78C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $7F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c01
	dc.w	DIWSTOP,$2c71
	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $88C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	dc.w    $8F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c02
	dc.w	DIWSTOP,$2c71
	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $98C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	dc.w    $9F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c03
	dc.w	DIWSTOP,$2c71
	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
    dc.w    $A8C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	; Third color block: Test DIWSTOP with horizontal values ...
	dc.w    $B701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B7B1,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC5
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $C701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC6
	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $D701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC7
	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $E001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $E701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E7D9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC8
	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $F001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Set DIWSTRT too late
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $005B,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cF1
	dc.w    DIWSTOP,$2cA1
	dc.w    $0101,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $0801,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $105D,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cF1
	dc.w    DIWSTOP,$2cA1
	dc.w    $1101,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $1801,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.l	$fffffffe
