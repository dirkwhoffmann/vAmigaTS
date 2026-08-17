## Objective

A sprite pixel is four buffer entries wide in lores and two in hires, and
neither edge of the display window lands on one of its boundaries. A sprite
crossing an edge therefore always has one pixel straddling it, and there are
two ways to treat that pixel: draw the part that is inside the window, or
discard it whole. The two differ by up to one screen column.

This test puts a straddling pixel at **both** edges of the same rasterline and
turns each into a yes/no question rather than a measurement.

```
left column     Sprite 0, COLOR17 black, and BRDRBLNK makes the border black
                too. Sprite and border merge, so the only thing that can
                separate them is playfield getting in between -- which happens
                exactly when the straddling pixel is discarded and the sprite
                starts a grid step late.

right column    Sprite 2, COLOR21 white, against the same black border. Beyond
                DIWSTOP there is only border, so a white pixel out there can
                only be a straddling pixel that was drawn whole instead of
                being cut at the edge.
```

Ten bands per section, both sprites one lores pixel further right in each, and
three sprite-free lines after every band showing where the two edges sit on
their own. Two sections, lores and hires, so nothing here needs AGA.

Colour 1 of a pair is COLOR17 for sprites 0/1 and COLOR21 for 2/3. Setting only
COLOR17 would leave sprite 2 in whatever the register happened to hold.

## What the left column shows

This is the edge the straddling pixel actually reaches, and the test that
distinguishes the two treatments:

```
                          g0 g1 g2 g3  g4 g5 g6 g7 g8 g9
pixel drawn in part        0  0  0  0   1  3  5  7  9 11    <- vAmiga now
pixel discarded whole      1  1  1  1   1  3  5  7  9 11
```

Groups 0 to 3 have the sprite clipped, so their strip cannot be the sprite
sticking out — it is the treatment of that one pixel and nothing else. Groups 4
upward are unclipped and measure geometry, which is the same either way.

A1200 and A500+ photographs of `../sprgate`, which asks the same question a
different way, read 0 in both resolutions on both machines. That is why vAmiga
draws the pixel in part: see `Denise::drawSpritePair`.

## What the right column shows, which is not what it was built for

Nothing sticks out. In every one of the twenty bands the white sprite ends at
column 701 and the border begins at 702, exactly where the sprite-free control
lines put it:

```
LORES  g0  sprite 680-701   border starts 702   control 702
       g9  sprite 698-701   border starts 702   control 702
HIRES  g0  sprite 680-701   border starts 702   control 702
       g9  sprite 698-701   border starts 702   control 702
```

The straddling question never arises at the right edge, because a sprite is not
cut there by the sprite code at all — **the border buffer covers it**. Past
DIWSTOP every entry is marked border, and the composite step takes the border
in preference to whatever the sprite wrote, entry by entry. So the cut is at
entry granularity for free, and `spriteClipEnd` (which is `PIXEL_CNT + 64`)
never fires.

That asymmetry is worth having on record: the two edges of the display window
are handled by different code with different granularity, and only the left one
needed fixing. It also means this half of the test cannot be made to fail by
any plausible change to the sprite clipping logic — it is a control, not a
measurement. The one thing it would catch is the border mask ceasing to cover
sprites, which is what `borderSprites()` deliberately does.

## Configurations

```
spredge_plus   A500_PLUS_1MB   ECS Agnus, ECS Denise
spredge_aga    A1200_2MB       AGA Agnus, AGA Denise
```

Both draw identically; the sprite pixel width in lores and hires does not
depend on the chipset.

Dirk Hoffmann, 2026
