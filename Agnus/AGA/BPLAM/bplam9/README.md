## Objective

bplam8 with the Pacman body **black** instead of `colour[BPLAM]`.

bplam7 paints the body in the colour the playfield draws its index-0 pixels
in, so the body disappears against the **picture**. bplam9 paints it in the
colour BRDRBLNK makes of the border, so it disappears against the **border**
instead. Half the subsections of this sweep run blanked, so both cases are on
screen at once.

Nothing else changes. Same window sweep in the same three DIWSTRT positions,
same bitplanes, same palette, same two columns at lores `$73` and `$1B9`, and
every second Pacman left out exactly as in bplam8 — `SPR_PERIOD` 36,
`SPR_REPS` 8, sixteen lines with a sprite and twenty with none.

`COLOR17` is written `$000` twice, once with LOCT clear and once with LOCT
set, so the register is black in all eight bits per component rather than
only in the high four.

## Why black is the interesting choice

It inverts every contrast in the picture, and the two colour schemes fail
differently:

```
bplam7, bplam8    body = picture colour
                  an error shows up as PICTURE where BORDER belongs

bplam9            body = blanked border colour
                  an error shows up as BORDER where PICTURE belongs
```

Two opposite schemes cannot be biased the same way by monitor bleeding, and
the Copper ruler is common to all of them. Whatever survives both readings is
not an artifact of the colours chosen.

## What each half of the picture does

**Blanked subsections — the silhouette by subtraction.** Body and border are
the same black, so there is no colour step anywhere near the window edge. The
black simply runs on out of the border and into the picture for as far as the
sprite survived. What is readable is therefore not an edge but the
*difference* between two lines of the same subsection: a sprite-free line
gives the unextended window edge, a sprite line gives edge plus surviving
sprite. bplam8's band structure is what makes both available at one DIWSTRT.

Over the sixteen lines of a band that difference traces the figure, one
number per rasterline. Super hires, "before", from the recorded reference:

```
sprite-free lines      43 43 43 ...          window edge, in columns
sprite lines           48 49 50 51 49 47 44 44 47 49 51 50 49 48 46 43
extension               5  6  7  8  6  4  1  1  4  6  8  7  6  5  3  0
```

That last row is the Pacman's left silhouette, drawn by subtraction, measured
without a single hard colour edge at the boundary being measured.

**Border-open subsections — the control.** The border is grey there, so a
black body is visible against border and picture alike and the whole figure
is legible on its own, in the same three DIWSTRT positions. It shows where
the sprite is without needing the subtraction.

## What the emulator draws

Extension of the black past the sprite-free window edge, in screenshot
columns, over the subsections that contain both kinds of line:

```
                    DIW        base    extension
lores  sub3 blnk    before      59       0
hires  sub5 blnk    overlap     74       0
shres  sub0 open    before      43       1 .. 8
shres  sub1 open    exact       43       0 .. 8
shres  sub4 blnk    exact       43       0, 3
shres  sub5 blnk    overlap     50       0, 1
```

**Only super hires shows anything.** In lores and hires the left column is
clipped away entirely, which bplam7 already measured (0 px surviving in both)
and which is a property of the sweep, not of this variant. Super hires draws
the sprite at half width and keeps 33 px of it, which is why the silhouette
is legible there and nowhere else.

The right column, which straddles DIWSTOP rather than DIWSTRT, is where the
black is most obvious to the eye. Last picture column, lores:

```
sprite lines        687 - 689
sprite-free lines   701
```

Twelve to fourteen columns of the picture eaten by the body, in eight bands
down the frame with sprite-free bands between them. That is the bite visible
at the right edge of the screenshot.

## What a photograph decides

The blanked super hires subsections are the ones to photograph. The extension
column above is a prediction with sub-pixel meaning and no bleeding at the
measured boundary: if the sprite gate and the bitplane gate coincide, the
last line of a band extends by 0 and the first by 5. A gate that opened
early for sprites would add a constant to the whole column, including the
zero — which is the same defect bplam8 caught, seen from the other side and
in a different colour.

Dirk Hoffmann, 2026
