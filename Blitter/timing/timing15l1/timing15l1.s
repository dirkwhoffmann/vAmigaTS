BLIT_BLTCON0        equ $0FCA
BLIT_BLTCON1		equ $0001

BLTSIZE1            equ (1)<<6|(1)
BLTSIZE2            equ (2)<<6|(1)
BLTSIZE3            equ (3)<<6|(1)
BLTSIZE4            equ (4)<<6|(1)
BLTSIZE5            equ (5)<<6|(1)

COL1                equ $BB6   ; Use highlighted color if channel A is enabled
COL2                equ $BB6   ; Use highlighted color if channel B is enabled
COL3                equ $BB6   ; Use highlighted color if channel C is enabled
COL4                equ $BB6   ; Use highlighted color if channel D is enabled
COL5                equ $6FB   ; Use highlighted color in fill mode
COL6                equ $6FB   ; Use highlighted color in single dot mode
COL7                equ $BB6   ; Use highlighted color in line mode

	include "../timing.i"
