## Objective

bplam4, rebuilt so that its left edge can be fitted to sub-pixel precision in **all three** resolutions.

Everything bplam4 measures is unchanged: BPLAM is a constant, the display window sweeps across the first bitplane pixel in three positions, each run twice, once with the border open and once with BRDRBLNK set. Only the thing immediately right of the left edge is different.

## Why bplam4 needed replacing for this

bplam4 puts its comb hard against the left edge. A bar is two screenshot columns in lores, one in hires. Photographed at 1024 pixels wide the scale is about 1.39 photo pixels per column, so:

```
             bar width      comb contrast in the A1200 photo
lores        2.78 px                129
hires        1.39 px                 26
```

The hires bars sit at the sampling limit and their contrast has collapsed to a fifth. An edge fit assumes a step from one flat level to another; against an aliased comb the apparent onset can move by up to half a bar, which is the same size as the effect being measured. That is why bplam4's photograph put the hires edge 1.44 columns away from the lores edge when both should sit in the same place, and why the hires question could not be settled from it.

## What changed

**A solid left margin.** The first two words of every bitplane are cleared, so the picture opens with a block of index 0 — colour[BPLAM] — before the comb starts. Index 0 is also what the shift registers deliver before the first word arrives, so the two merge and the border-to-picture transition is a single clean step with a flat plateau on both sides:

```
              plateau right of the edge, in screenshot columns
lores                 68
hires                 35
super hires          658
```

Against bplam4, where the luminance varies by 99 over the 28 columns right of the edge, bplam6 varies by 0.

**The bitplane pointers are rewound on every line**, not once per subsection. Without that the margin would appear only on the first line of each block, since the planes stream on from where the previous line left them. It also makes every line of a subsection identical, so an edge can be fitted on each of the fourteen and averaged.

## How to measure it

Photograph it, then fit an error function to the left edge rather than crossing a threshold. The ruler calibrates the fit: its red and green stripes are unique in the frame and anchor the scale, and its thirty-seven white/blue boundaries sit at known columns 37+16j, so running the same fit over them gives the blur and the fit's own bias before it is applied to the picture. On the bplam4 photograph that calibration came out at −0.50 columns with a scatter of 0.82 over the thirty-seven boundaries.

Use the BRDRBLNK subsections. The border is pure black there, which is the largest step available.

## What the emulator currently draws

Left edge, in screenshot columns, identical with the border open and blanked:

```
             before   exact   overlap
lores          60      60       74
hires          60      60       74
super hires    44      44       50
```

These are the values a photograph has to be compared against. They already carry the `BPLDAT_LATENCY` of 8 and the corrected super hires fetch order, so they are not the numbers in bplam4's own README.

## What the A1200 photograph says

Measured with the affine/erf fit described above. The photograph is rotated 180 degrees and tilted enough that no image row corresponds to a rasterline, so the six ruler landmarks define an affine map and the luminance is sampled *along* each rasterline before fitting.

```
sec     sub        photo   vAmiga   error (columns)   rows   sd
lores   before     57.90     60         -2.10          11   0.08
lores   exact      58.10     60         -1.90          11   0.10
lores   overlap    73.30     74         -0.70          11   0.06
hires   before     59.40     60         -0.60          11   0.06
hires   exact      59.60     60         -0.40          11   0.05
hires   overlap    74.70     74         +0.70          11   0.06
shres   before     44.50     44         +0.50          11   0.09
shres   exact      44.80     44         +0.80          11   0.11
shres   overlap    51.90     50         +1.90          11   0.11
```

**The margin did its job.** Row-to-row scatter is 0.05 to 0.11 columns, against the ±1.5 that bplam4 managed, and hires now fits as well as lores instead of being unreadable.

The absolute errors still scatter by about two columns between sections, because the affine map leaves residuals of up to 10 px at the ruler landmarks — the display and the lens are not perfectly rectilinear. What is *not* affected by that is the distance between two edges a few columns apart on the same rows, so each section is best read against its own DIW-limited subsection, where vAmiga's DIW comparator is already known to agree with the hardware:

```
                    data-limited edge minus DIW-limited edge
                    photo      vAmiga     difference
lores               -15.30      -14         -1.30
hires               -15.20      -14         -1.20
super hires          -7.25       -6         -1.25
```

**All three agree to a tenth of a column.** The data gate is 1.25 columns earlier on the A1200 than vAmiga puts it, and it is the same 1.25 columns in every resolution.

## What that settles

**hires behaves exactly like lores.** bplam4's photograph put hires within 0.3 columns while lores was 1.8 out; that difference was the aliasing artifact this test was built to remove, and it is gone. The bplam5 notch, which showed the same two-column gap in both lores and hires, was reading the hardware correctly.

So the gate is not resolution dependent, and `BPLDAT_LATENCY` should come down. The size is 1.25 columns, which is 2.5 buffer entries: **5 or 6 rather than 8.** The measurement cannot split those two. It does argue against 4 — a full lores pixel of correction would be 2 columns, half again more than the photograph shows.

One thing to note in passing: the super hires *overlap* edge sits 1.9 columns right of where vAmiga draws it, where lores and hires are within 0.7. That subsection is DIW-limited, so it hints at something in the super hires DIW comparison rather than in the fetch. It is a separate question from the one this test was built for.

## The question it exists to answer

At a latency of 8 the A1200 photograph of bplam4 puts lores about 1.8 columns left of where vAmiga draws it and hires only 0.3 — but the hires figure is the unreliable one, for the reason above. Separately, bplam5 shows a two-column notch in **both** lores and hires that the A1200 does not have, which argues that hires wants the earlier gate as much as lores does.

Those two readings disagree, and one lores pixel of latency hangs on it. bplam6 is the tie-breaker: if its hires edge photographs at the same offset as its lores edge, the notch is right and the latency should come down; if hires again lands close to what vAmiga draws while lores does not, the gate is genuinely resolution dependent.

Dirk Hoffmann, 2026
