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

#### bltdpt1

This test verifies that the first word is written to the D channel and not the C channel. If everything works fine, the lines are drawn in green. Otherwise, the lines appear yellow.


Dirk Hoffmann, 2021
