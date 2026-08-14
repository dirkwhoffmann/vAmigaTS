## Objective

Verifies BRDRBLNK, bit 5 of BPLCON3. With it clear the border outside the display window is painted in the background colour, COLOR00, exactly as on OCS. With it set the border is forced to pure black instead, which is what lets a program use a non-black COLOR00 inside the window without the whole screen surround taking that colour too.

The bit only has an effect when ECSENA (BPLCON0 bit 0) is set, so ECSENA is on throughout this test, including on the lines where the bitplanes are switched off.

Two things are under test, and they are separable:

- does a BRDRBLNK write take effect **at all**, and on the right line?
- does it take effect **at the pixel where it was written**, or only per whole rasterline?

#### The picture

COLOR00 is orange, COLOR01 is blue, and a single bitplane is filled with solid `$FFFF`. Every pixel inside the display window is therefore index 1 and comes out blue, and the border is the only thing COLOR00 can reach:

```
border, BRDRBLNK clear   orange
border, BRDRBLNK set     black
display window           blue, unaffected either way
```

Three colours that cannot be confused, with the window acting as a fixed landmark between the two border halves. On the lines where the bitplanes are disabled the window turns orange as well, because index 0 reaches COLOR00 there — that makes the window edges themselves visible, and the last region uses it.

#### The four regions

**Region 1, lines $30-$4F — large border, whole-line switching.** A narrow window (DIWSTRT $2CA1, DIWSTOP $2C41) leaves a wide border on both sides. BRDRBLNK is switched at the very start of a line and left alone for the rest of it, two lines set followed by two lines clear, all the way down. The result is a horizontal bar pattern in both borders.

Nothing else is written in this region — **in particular the display window registers are not touched after the region begins**. That is deliberate. An implementation that recomputes its border mask only when the display window changes will show a single uniform border here instead of bars, and this is the region that catches it.

**Region 2, lines $50-$8F — large border, mid-line switching.** Same narrow window. BRDRBLNK is now set part way across the line and cleared again before the line ends, the set position sweeping the left border and the clear position sweeping the right one, both advancing down the screen. The blanked stretch therefore walks to the right as the eye travels down, forming a staircase in each border.

A machine that applies the write at the pixel where it happens draws that staircase. A machine that applies it to the whole rasterline draws solid bars again, with no horizontal structure at all.

**Region 3, line $90 — the Copper timing ruler** from Agnus/DDF/ddf1.

**Region 4, lines $94-$D3 — small border, switching read against a ruler.** The window widens to DIWSTRT $2C81 / DIWSTOP $2CA1, leaving a thin but still clearly visible border on each side. The region is eight blocks of eight lines. Each block opens with two ruler lines that carry **no BRDRBLNK writes at all**, so the scale is undisturbed, followed by six display lines on which BRDRBLNK is set at a position that advances by one ruler stripe per block. The stripe at which the border changes colour can then be counted off directly against the ruler immediately above it.

#### Known limitation

vAmiga passes region 1 but not region 2. Its border mask is built once per rasterline in the hsync handler, from a single border colour, so BRDRBLNK is a per-line property there: region 2 comes out as uniform bars with no horizontal structure, and region 4's switch position cannot be read against the ruler at all. Only whole-line switching is reproduced.

Making the border follow BRDRBLNK within a line means giving the border mask a change history of its own, the way the display window already has one, rather than a scalar colour per line. Until then region 2 and region 4 measure a real difference from hardware rather than agreement with it.

Region 1 is also one line late at its very first line, where the display window registers and BPLCON0 are written on the same line; every block after that lines up exactly with the Copper.

#### Notes on the source

The ruler train ends by leaving COLOR00 black. Every ruler in this test is therefore followed by a wait and a write putting the orange back, without which the whole screen below the first ruler would have a black border for a reason that has nothing to do with BRDRBLNK. Tests whose COLOR00 is black anyway do not need this and do not do it.

The window in region 4 is deliberately not the usual DIWSTRT $2C71 / DIWSTOP $2CC1. That window is so wide that both borders fall almost entirely outside the captured area, leaving nothing to look at; $2C81 / $2CA1 keeps the border small but on screen.

BPLxMOD is zero and the single buffer repeats every word, so pointer drift is invisible.


## Regression testing

Run under two configurations, `_plus` (A500_PLUS_1MB, ECS Denise, BRDRBLNK active) and `_ecs` (A500_ECS_1MB, OCS Denise, BRDRBLNK inert). The collection README explains the pair.

The two references differ wherever the test blanks the border, and nowhere else.


Dirk Hoffmann, 2026
