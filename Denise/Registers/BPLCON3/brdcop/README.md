## Objective

The window edge, drawn twice on alternating bands — once by Denise's border
logic and once by the Copper — so that a photograph answers "do these agree?"
without any calibration at all.

Every other test in this suite that measures the left edge of the picture ends
up fitting an edge off a photograph against a Copper ruler: an affine map, a
blur estimate, an erf fit, and a residual of a few tenths of a column. This
one asks whether a vertical edge is **straight**, which survives monitor
bleeding because both bands are blurred identically.

## The three band types

Fifteen bands of five lines per section, three types in rotation:

```
COPPER     BRDRBLNK clear and BPU = 0, so there is no window and the whole
           line is border showing COLOR00. COLOR00 starts the line black;
           one Copper MOVE turns it grey. The step is placed by the Copper.

REF_DIW    BRDRBLNK set, one bitplane of zeros, DIWSTRT moved to the right
           of the bitplane data. Border is forced black, the window shows
           index 0 which is grey, and the DIW comparator places the edge.

REF_DATA   The same with DIWSTRT back to the left of the data, so the first
           BPL1DAT write is what opens the window. The data gate places the
           edge.
```

`COLOR01` is grey as well, so the bitplane content is irrelevant — the
reference bands are about where the window starts, not what is in it.

Each COPPER band carries a marker: `COLOR00` goes red for eight colour clocks
in the middle of the line and back to grey. Without it, a correct picture
would be indistinguishable from one where the Copper list never ran.

Both kinds of band also return to black near DIWSTOP, the reference bands
because the window closes and the COPPER bands because a MOVE puts it back, so
the right edge is a second instance of the same comparison.

## Two things that bit this test while it was being written

**A Copper WAIT can only name an odd horizontal position.** Bit 0 of the first
word is the instruction flag; the position field is bits 7-1. An even value
assembles into a MOVE to whatever register bits 8-1 happen to address. The
first version of this test used `$80`, `$88` and `$E0`, and the whole frame
came out a single flat red — one stray MOVE is enough.

**The Copper can therefore never land exactly on the data gate.** Positions
are two colour clocks apart, which is eight screen columns, and they fall on
columns ≡ 5 (mod 8). The data gate lands on columns ≡ 3 (mod 8): moving
DDFSTRT shifts it by four colour clocks, sixteen columns, which preserves the
residue, and changing the bitplane count shifts it by whole colour clocks,
four columns, which flips it between 3 and 7. So **2 columns is the smallest
offset obtainable**, and it is built into the test deliberately. DIW edges are
always even, so those cannot coincide with a Copper position either; 1 column
is the best there.

That is a property of the instrument, not a defect. What a photograph decides
is whether the offsets it shows are the ones vAmiga shows.

## What the emulator draws

Left edge, in screenshot columns:

```
                COPPER   REF_DIW   REF_DATA    cop−diw   cop−data
AGA   lores       61        62        59          −1        +2
      hires       45        46        43          −1        +2
      shres       37        38        35          −1        +2
ECS   lores       60        62        59          −2        +1
      hires       44        46        43          −2        +1
      shres       36        38        35          −2        +1
```

Uniform across all three resolutions, which is the first thing to check on a
photograph: the serration at the band boundaries has to look the same in every
section, even though the data gate itself sits in a different column in each
(59, 43, 35 — one bitplane fetches in 8, 4 and 2 colour clock groups, so
BPL1DAT is written progressively earlier).

The right edge sits at 701 for both reference types and 704 for COPPER, a
constant +3 in every section and both chipsets.

## A free measurement of the AGA colour delay

The COPPER column moves by one between the two chipsets and the reference
columns do not. That is exactly what should happen: the COPPER band's edge
**is** a colour register write, and AGA delays those by one hires pixel, while
neither the DIW comparator nor the data gate is a colour write.

```
              cop−diw    cop−data
AGA             −1         +2
ECS             −2         +1
```

So brdcop measures `COLOR_LATENCY` as a one column change in the size of the
step, independently of `../COLOR/colorlag` and `../COLOR/rulevern`, and
without fitting anything. On a photograph it reads as: the serration at the
band boundaries is one column wider on an A500+ than on an A1200.

## What a photograph decides

```
COPPER sits 2 columns right of REF_DATA on the A1200
    the data gate agrees with the Copper's clock, and BPLDAT_LATENCY is right

COPPER sits 1 column right of REF_DIW
    the DIW comparator agrees too

any section serrating differently from the others
    the gate is resolution dependent in a way vAmiga does not model

no red marker
    the Copper list did not run; nothing else in the picture is meaningful
```

Super hires is inert on ECS Denise, so the third section of `brdcop_plus`
repeats the lores geometry. BRDRBLNK itself does work there, which is why the
`_plus` reference is worth having.

Dirk Hoffmann, 2026
