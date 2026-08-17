## Objective

Verifies super hires, BPLCON0 bit 6, the AGA display mode that halves the pixel again below hires. The question the suite asks is the one the FMODE suite asked about hires: **how many bitplanes can super hires actually fetch, and does FMODE change the answer?**

That question has a precedent. At FMODE = 0 a hires line fetches only bitplanes 1 to 4, because the fetch unit has no slots for planes 5 to 8, and a non-zero FMODE widens the fetch and lifts the limit to 8. Super hires packs four times as many pixels into a color clock as lores, so whatever its limit is, it should be tighter still.

#### The claim under test

vAmiga's answer is unambiguous, which is what makes it worth checking. `Sequencer::computeBplEventTable` enumerates hires bitplane counts 1 through 8, but for super hires it enumerates only 1 and 2 — and anything above 2 does not degrade gracefully, it falls through to the zero-bitplane fetch unit:

```
case Resolution::SHRES:
    switch (bpu) {
        case 1: computeShresFetchUnit <1> (fm); break;
        case 2: computeShresFetchUnit <2> (fm); break;
        default: computeShresFetchUnit <0> (fm); break;
    }
```

So vAmiga predicts a picture at BPU 1 and 2 and **a black band at BPU 3 through 8** — and it predicts that regardless of FMODE, because the plane count is capped before FMODE is consulted (the function takes `fm`, the switch does not). If an A1200 paints anything at all in the BPU 3 sections, or if a wider FMODE lifts this cap the way it lifts the hires one, that is a real finding.

#### shres00, shres01, shres10, shres11

The four FMODE values ($0-$3), one per test. Each is a thin wrapper that defines FMODE and includes shres.i.

Every frame holds two regions of 8 sections, enabling 1 to 8 bitplanes:

```
lines $30-$8F   HIRES, the reference
line  $90       the copper timing ruler from Agnus/DDF/ddf1
lines $94-$F3   SHRES, under test
```

The hires region is not decoration, it is the control. It says what this FMODE value can fetch when the pixel is merely half a lores pixel rather than a quarter of one, and it is already characterised by the FMODE tests. Reading a super hires section against the hires section directly above it separates "super hires cannot do this" from "this FMODE cannot do this".

Note that BPLCON0 bit 6 alone selects super hires. The HIRES bit is not also set, and is ignored once bit 6 is set.

#### The picture

Deliberately duller than the FMODE tests' staircase. Every bitplane is filled with a pattern that repeats every single word — plane 1 gets `$CCCC` (two pixels on, two off), planes 2 to 8 get solid `$FFFF` — so with N planes enabled the color index alternates between 2^N-1 and 2^N-2 straight across the line. Each section is one flat hue carrying a fine two-pixel comb. The palette is the FMODE suite's: hue keyed on the highest set bit, brightness on bit 0, so the hue counts the bitplanes that arrived and the plane 1 comb never makes that count ambiguous.

The word-periodic pattern is the point. It makes the picture completely independent of how many words a line fetches, so nothing here can shear or drift whatever super hires turns out to do with the DDF window, and a black band means "no data arrived" rather than "the data landed somewhere unexpected". The comb also comes out four times finer in super hires than in hires, which is an independent confirmation that the mode really engaged.

BPLxMOD is zero and the pointers are reloaded once per section, purely to keep the buffers small.


Dirk Hoffmann, 2026
