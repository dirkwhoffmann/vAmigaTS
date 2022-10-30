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

#### line12, line13

Same as line1 with invalid values for the width parameter (must be 2 to make the Blitter work correctly).

#### mask1, mask2, mask3

Same as line1 with unusual values in BLTADAT and the two mask registers.

#### channels1, channels2

Iterates through all 16 combinations of the channel enable bits.

#### channels3

Special test case for exhibiting the undocumented "channel B feature". If channel B is enabled, BLTBDAT is constantly updated by DMA data which destroys the line pattern. If the feature is supported, you'll see striped lines. If not, a solid horizontal bar is visible. 

#### channels4

This test verifies that the first word is written to the D channel and not the C channel. If everything works fine, lines are drawn in green. Otherwise, lines appear yellow.

#### start1, start2

Like line1 with varying start values for each line.

#### combined1

This test runs a line blit followed by a copy blit. The line blit will modify the ASH bits in BLTCON0 which means that the copy blit is carried out with a shift. As a result, the two dashed lines at the top get disaligned.

#### combined2

This test runs two line blits in a row. The second blit runs with the value of BLTCON1 as it was left by the first blit. The test has been setup such that the SIGN bit changes during the first blit. It is 0 when the first blit starts and 1 when the first blit ends. The form of the center pixel in the test picture reveals that the second blit starts with the SIGN bit equal to 1.

#### bsh1

This test draws multiple dashed lines with different values in BLTCON1::BSH.

#### bsh2

Same as bsh1, but BLTCON1 is only written prior to the first blit. All other blits use the value of BPLCON1 as it was left by the previous blit.

#### bsh3 

This test performs multiple blits with the B channel enabled and different start values in BLTCON::BSH.
 
#### zero1

This test runs 12 line blits. Each blit draws a horizontal line with varying line patterns and multiple combinations of the SING and USEC bit. After each blit, the value of the Blitter zero bit is read and visualized in form of a blue or yellow line.


Dirk Hoffmann, 2021
