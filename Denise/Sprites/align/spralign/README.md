## Objective

Do the sprite and the bitplane coordinate systems agree?

The same stripe pattern is drawn twice over the same ground: once by one bitplane and once by eight sprites, in the same colour and with the same period. Where the two agree the sprites cannot be seen at all.

Reading a position off a photograph of a real monitor is limited by colour bleeding between neighbouring pixels. This test does not ask for a position to be read — it asks whether something disappears, which survives bleeding far better.

## The control

A pattern that is invisible when correct is worthless without proof that it is being drawn. Each section is split in half. The upper half sets the sprite colour to the bitplane stripe colour, so a correct sprite vanishes; the lower half sets it to red, so the same sprites appear in the same places and their alignment can be read directly.

Colour 1 of **every** sprite pair has to be set — 17 for sprites 0/1, 21 for 2/3, 25 for 4/5, 29 for 6/7. Setting only COLOR17 leaves six of the eight sprites in whatever those registers happen to hold, which is how the first version of this test came out.

## The three sections

A sprite pixel is one lores pixel wide in lores and in hires, and half of one in super hires, so the sprite data is `$F0F0` in the first two sections and `$FF00` in the third to draw the same stripe. A sprite therefore covers two stripe periods in lores and hires but only one in super hires.

The super hires buffer is filled with the empty word first. Its data starts eight screen columns left of the other two sections, which would otherwise put it half a period out of phase and drop the sprites into the gaps.

The stripe period is eight lores pixels, four on and four off — a whole number of pixels in every resolution and every sprite width.

## What it found

With `HSTART` set to the first bitplane pixel at lores `$7F`, the sprite lands **one lores pixel left** of the playfield stripe: the white run comes out ten columns where it should be eight. `HSTART` is therefore `$80` here, calibrated so that vAmiga draws the sprites invisible, which turns the photograph into a yes/no test of whether the hardware agrees.

BRDRBLNK is set on the data lines, so the border is pure black and the absolute position is readable against it as well as against the two Copper ruler lines at the top of each section.

Dirk Hoffmann, 2026
