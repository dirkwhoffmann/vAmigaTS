## Objective

Modify DDFSTART and DDSTOP in various ways. Note that the result differes between OCS Agnus and ECS Agnus. The old OCS Agnus ignores bit H1 in both DDFSTRT and DDFSTOP. 

#### dmaslots

This test enables 6 bitplanes in lowres modes in the upper half of the screen and three bitplanes in hires mode in the lower half. The Copper is utilized to draw color stripes. From one red line to the next, DDFSTRT and DDSTOP are shifted to the right by 2 which causes the fetch units to shift, too. The position of the Copper lines exhibit the position of the fetch units (the Copper can't start at arbitrary positons because of heavy bitplane DMA. Only a few slots remain free and can thus be used by the Copper).

#### ddf1 - ddf10

These tests set DDFSTART and DDFSTOP to different combinations inside the valid range. The upper part of the screen is drawn in lores mode and the lower part in hires mode.

#### doublematch1

This test sets DDFSTRT and DDFSTOP to the same value. In the upper half, the double matching cycle is reached while bitplane DMA is off. In the lower half, it is reached while bitplane DMA is on.

#### farright1

Sets DDFSTOP to very high coordinates.

#### reenable1

In this test, DDFSTRT and DDFSTOP triggers several times in the same scanline.

#### shift1 - shift3

Uses DDFSTART and DDFSTOP in combination with BPLCON1. The tests visualize how the bitplane shift value affects the DDF window.

#### shift4 and shift5

Similar to shift3 with different shift values for even and odd bitplanes.

#### lupo1

This test mimics parts of the Copper list of "Lupo Alberto (1991)(Idea)" which failed in earlier versions of vAmiga.


Dirk Hoffmann, 2020 - 2022
