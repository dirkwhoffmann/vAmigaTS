## Objective

Perform elementary line Blitter tests.

#### line1, line2

Draws lines in all 8 octants with the SIGN flag cleared or set, respectively. Note the small difference in the center area.

#### line3, line4

Same as line1 and line2 with a dot pattern in BLTBDAT.

#### line5, line6

Same as line1 and line2 with the SING bit set (single pixel mode).

#### line7, line8

Same as line5 and line6 with a custom pattern in BLTBDAT.

#### line9, line10

Same as line7 and line8 with a different pattern.

#### line11

Same as line1 with a different starting point (center is slightly shifted).

#### channels1, channels2

Iterates through all 16 combinations of the channel enable bits.

#### channels3

Special test case for exhibiting the undocumented "channel B feature". If channel B is enabled, BLTBDAT is constantly updated by DMA data which destroys the line pattern. If the feature is supported, you'll see striped lines. If not, a solid horizontal bar is visible. 

#### start1, start2

Like line1 with varying start values for each line.

#### combined1

This test runs a line blit followed by a copy blit. The line blit will modify the ASH bits in BPLCON0 which means that the copy blit is carried out with a shift. As a result, the two dashed lines at the top get disaligned.


Dirk Hoffmann, 2021
