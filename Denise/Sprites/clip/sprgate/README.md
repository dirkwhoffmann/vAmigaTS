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

## One oddity, not yet explained

In the **hires** section of `sprgate_plus`, groups 0 and 2 draw a two-column
sprite on some of their five lines instead of the full width, and one line
comes out as a comb — the sprite data is being fetched out of step. The lores
section is clean, all three sections of `sprgate_aga` are clean, and the gap
reading is unaffected (it is 1 on every line of every band in groups 0 to 4).

It is left in rather than tuned away because it may be a real ECS sprite-DMA
bug worth chasing separately. **Read the lores section**; it answers the
question on its own.

Dirk Hoffmann, 2026
