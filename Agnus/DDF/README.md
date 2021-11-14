## Objective

Modify DDFSTART and DDSTOP in various ways. Note that the result differes between OCS Agnus and ECS Agnus. The old OCS Agnus ignores bit H1 in both DDFSTRT and DDFSTOP. 

#### ddfnew1 - ddfnew10

These tests set DDFSTART and DDFSTOP to different combinations inside the valid range. The upper part of the screen is drawn in lores mode and the lower part in hires mode.

#### farright1

Sets DDFSTOP to very high coordinates.

#### shift1 - shift3

Uses DDFSTART and DDFSTOP in combination with BPLCON1. The tests visualize how the bitplane shift value affects the DDF window.

#### shift4 and shift5

Similar to shift3 with different shift values for even and odd bitplanes.

#### lupo1

This test mimics parts of the Copper list of "Lupo Alberto (1991)(Idea)" which fails in vAmiga.


Dirk Hoffmann, 2020
