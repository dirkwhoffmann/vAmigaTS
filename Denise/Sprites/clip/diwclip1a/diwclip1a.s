;
; diwclip1a -- DDFSTRT $0038. See diwclip.i for what the picture means.
;
; This one differs from diwclip1 in one bit: BRDRSPRT, BPLCON3 bit 1, is
; set for the whole frame. See the "BORDER SPRITES" section of diwclip.i.
;
DDF_START           equ $0038
CON3_MAIN           equ $0022          ; BRDRBLNK + BRDRSPRT
CON3_SHRES          equ $0002          ; BRDRSPRT alone, border NOT blanked

	include "../diwclip.i"
