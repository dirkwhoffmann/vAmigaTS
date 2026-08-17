## Objective

When the display window opens, does the leftmost sprite pixel arrive at the
same moment, before it, or after it? — asked with nothing but OCS/ECS
features, so the answer can be compared against `Agnus/AGA/BPLAM/bplam9`.

bplam9 measured this on an A1200 and found the sprite arrives **one screen
column after** the window opens: there is exactly one column of playfield
between the last border pixel and the first sprite pixel. vAmiga models that
with `SPRITE_LATENCY = BPLDAT_LATENCY + 2`, which is chipset independent in
the code and has never been checked on anything but AGA. bplam9 cannot check
it: BPLAM is an AGA register and the effect was only legible in super hires,
which ECS Denise does not have.

## Counting, not measuring

The trick is bplam9's — make the sprite **the same colour as the border**, so
the two merge and the only thing that can separate them is playfield getting
in between. BRDRBLNK forces the border to pure black and `COLOR17` is black:

```
sprite clipped by the window    black border runs straight into black
                                sprite; nothing to see

sprite clear of the window      black border, a strip of blue playfield,
                                then the black sprite
```

Ten bands per section, the sprite one lores pixel further right in each. The
reading is not a width or a position but **which band is the first to show
blue between the border and the sprite**, and how wide that strip is where it
is narrowest. Counting bands survives any amount of colour bleeding.

Every band is followed by three lines with no sprite at all, which show where
the window edge sits on its own — each band carries its own reference on the
rasterlines directly above and below it.

The third section repeats the first with **BRDRBLNK cleared**, so the border
takes `COLOR00` and is blue like the playfield. The black sprite is then
visible against blue on both sides, which shows where each sprite really is
and proves all ten are drawn. Without it, a picture in which the sprites never
appeared would look like a valid result.

## What the emulator draws

Width of the blue strip between the border and the sprite, in screenshot
columns:

```
group             0   1   2   3   4   5   6   7   8   9
lores HSTART     7B  7C  7D  7E  7F  80  81  82  83  84
      gap         1   1   1   1   1   3   5   7   9  11
hires HSTART     73  74  75  76  77  78  79  7A  7B  7C
      gap         1   1   1   1   1   3   5   7   9  11
```

Identical on `A1200_2MB` and `A500_PLUS_1MB`, which is the prediction under
test: `SPRITE_LATENCY` is chipset independent in vAmiga.

Two things to read off a photograph:

**The plateau.** Groups 0 to 4 have the sprite clipped by the window, so the
strip cannot be the sprite sticking out — it is the latency itself. If the
lag is real, five bands in a row show a thin blue line at the left edge. If
there were no lag, or a lead, the black would run straight through and the
plateau would be **0**, with no blue anywhere until group 5.

**Where the staircase starts.** The gap grows by two columns per lores pixel
from group 5 onward. A latency error of one column moves the whole staircase
by one band.

## The reading

```
five bands with a hairline of blue, then 3, 5, 7, 9, 11
    the lag is real on this chipset too, and is one column

no blue until the sixth band, then 2, 4, 6, 8, 10
    there is no lag on this chipset; SPRITE_LATENCY is AGA-only

blue in every band including a wide first one
    the sprite is not being clipped at all; check the third section
```

## Configurations

```
sprgate_plus   A500_PLUS_1MB   ECS Agnus, ECS Denise -- the one to photograph
sprgate_aga    A1200_2MB       for a like-for-like comparison with bplam9
sprgate_ecs    A500_ECS_1MB    ECS Agnus, OCS Denise
```

`sprgate_ecs` pairs an ECS Agnus with an **OCS** Denise, where BRDRBLNK does
nothing. The border takes `COLOR00` there, so the whole picture behaves like
the third section and the merge trick is unavailable. It is recorded as a
third data point, but the question above cannot be answered from it.

## A bug this test had, and what it means for the photographs

The first version set `BPL1MOD` to -40 for the whole picture. That is right for
lores, where a single bitplane fetches 20 words, but the hires section fetches
40:

```
DDFSTRT $38, DDFSTOP $D0, one bitplane
    lores   (D0-38)/8 + 1 = 20 words = 40 bytes
    hires   (D0-38)/4 + 2 = 40 words = 80 bytes
```

So the hires section advanced its pointer by 40 bytes per line, left the 128
byte buffer after three lines, and displayed the sprite list — and then
unrelated memory — as bitplane data. By the end of that section the pointer was
3200 bytes past the buffer, and the third section carried on from there.

**vAmiga hid this and an A1200 did not.** The memory the pointer walked into
reads as zeros in the emulator, so both the hires and the third section looked
perfectly clean; on real hardware they showed fragments and a nearly empty
field. The emulator output for those two sections was byte-identical before and
after the fix, which is exactly why the divergence only appeared on a
photograph.

The modulo is now set per section. Every line of every group is identical in
all three sections and hires reproduces the lores reading exactly.

**The lores section was never affected** — its modulo was correct from the
start, and its pixels are byte-identical between the two builds. So any
measurement already taken from the lores section of an existing photograph
still stands. Photographs of the hires and third sections taken before this fix
show the bug rather than the test, and are worth retaking.

## A footnote on the two blacks

The border is blanked and the sprite is `COLOR17 = $000`, and on a photograph
those are **not the same black**. Interior areas, away from any edge:

```
              BRDRBLNK border   COLOR $000 sprite   difference
A1200            15.5 +/- 3.4      25.7 +/- 3.5      +9.6 .. +10.9
A500+            12.3 +/- 2.1      13.7 +/- 2.0      +0.8 .. +2.0
```

BRDRBLNK drives the output to the blanking level; `$000` is the lowest active
level the colour DAC reaches. The pedestal between them is large on an A1200
and small on an A500+, and vAmiga models neither — both sides come out
`000000`.

It does not affect the reading above. This test counts whether *playfield*
appears between border and sprite, and playfield is a different colour from
either black. But it does mean the merge is not perfect on a photograph: the
sprite is faintly visible against the border, more so on an A1200. Do not
mistake that step, or the display's overshoot at it, for the strip being
measured. `../../../../Agnus/AGA/BPLAM/bplam9` has the full measurement.

Dirk Hoffmann, 2026
