BLIT_BLTCON0        equ $01CA
BLIT_BLTCON1		equ $0000

COL1                equ $6BF   ; Use highlighted color if channel A is enabled
COL2                equ $6BF   ; Use highlighted color if channel B is enabled
COL3                equ $6BF   ; Use highlighted color if channel C is enabled
COL4                equ $BB6   ; Use highlighted color if channel D is enabled
COL5                equ $6BF   ; Use highlighted color in fill mode
COL6                equ $6BF   ; Use highlighted color in single dot mode
COL7                equ $6BF   ; Use highlighted color in line mode

	include "../irqtim.i"
