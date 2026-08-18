## Objective

The AGA counterpart of the Agnus/DDF/DDF suite. Each test fixes **DDFSTOP** and sweeps **DDFSTRT**, showing three sections for lores, hires, and super hires. Each section contains eight subsections with 1–8 bitplanes.

The suite tests one `(DDFSTRT, DDFSTOP, FMODE)` combination across all resolutions and bitplane counts. Tests `agaddf1`–`agaddf10` use `FMODE = 0`; `agaddf11`–`agaddf18` repeat selected DDFSTRT values with `FMODE = 1` and `3`.

### Reading the picture

The border is blanked to black, while `COLOR00` is dark grey (`$444`). This makes the two edges of the bitplane data easy to see:

```text
black         border
fine comb     bitplane data
dark grey     display window after the data
black         border
```

The **left edge** is the first pixel produced by `DDFSTRT`; the **right edge** is the last pixel allowed by `DDFSTOP`. The two Copper rulers provide the scale.

The picture is intentionally asymmetric: the display window opens with the first `BPL1DAT` write, so there is no grey area before the first bitplane pixel. The grey area after the data is the useful indication that the window is still open.

Each subsection uses the same `$AA` bit pattern on all enabled bitplanes. Consequently, the data appears as a fine comb, with a different colour for each number of enabled planes.

### What to look for

The suite primarily measures the **left edge**. As `DDFSTRT` increases, the edge should move by the expected amount. Comparing the three sections shows how the same fetch timing maps to lores, hires, and super hires.

The expected number of usable bitplanes depends on `FMODE`:

```text
FMODE 0     lores 8   hires 4   super hires 2
FMODE 1, 2  lores 8   hires 8   super hires 4
FMODE 3     lores 8   hires 8   super hires 8
```

Subsections beyond these limits are expected to be completely black because no bitplane data is fetched.

`DDFSTRT` is also quantised to the fetch unit, so the left edge moves in steps rather than continuously.

### FMODE tests

The first ten tests use:

```text
DDFSTOP $00C8   FMODE $0000
```

with `DDFSTRT` from `$38` through `$4A`.

Tests 11–18 extend this to the wider fetch modes:

```text
             FMODE 1          FMODE 3
agaddf11/15  DDFSTRT $38
agaddf12/16  DDFSTRT $3C
agaddf13/17  DDFSTRT $40
agaddf14/18  DDFSTRT $44
```

These values include both lores-aligned and unaligned positions. The important comparison is the **offset of the first pixel** in each resolution. The slope is expected to remain constant; differences in offset reveal where the fetch and display logic disagree.

### Scrambled FMODE 3 tests

On a real A1200, **`agaddf16`, `agaddf17`, and `agaddf18` produce scrambled output in the lores section**. 


Dirk Hoffmann, 2026
