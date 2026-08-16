## Objective

Does the Copper ruler land where the bitplane data does?

A Copper ruler is nothing but a train of COLOR00 writes, and most measurements in this suite are read against one. This test asks whether the ruler and the bitplane data agree about where a given screen position is — without asking anyone to read a position off a photograph.

Both draw the same stripes, eight lores pixels of white and eight of blue, but never on the same line. Bands of four ruler lines alternate with bands of four data lines down each section. Where the two agree every vertical edge runs straight through the band boundaries; where they disagree the edges step, and the step is the error.

That is a continuity question rather than a position question, which is what makes it survive a photograph: bleeding blurs an edge but it does not move one edge relative to the one directly above it.

## Why the ruler lines carry no bitplanes

A ruler drawn on a line that also fetches bitplanes drifts. The fetch takes Copper slots, the train stretches, and forty back-to-back moves come apart after about sixteen stripes — which is what the first version of this test did, and what `colorlag` claims does not happen. Switching the bitplanes off for the ruler lines removes the competition and the train stays regular right across the line.

The cost is that a ruler line has BPU = 0, so its window never opens and BRDRBLNK would blacken it end to end. BRDRBLNK is therefore cleared on the ruler lines and set on the data lines — which also means every data line still shows a hard black border to read absolute position against.

## Getting the two into phase

The data has to be slid under the ruler, because where it starts depends on the resolution. BPLCON1 does it, in steps of one lores pixel: `$44` in lores and hires, `$00` in super hires. Without that the sections sit seven, seven and minus one columns out.

The control shifts the ruler train half a stripe, `HP $33` against `$31`, in the lower half of every section. A whole-stripe shift would be invisible; the first attempt used `$39`, which is two whole stripes, and showed nothing at all.

## What to expect

On AGA, colour register writes are delayed by one hires pixel and bitplane data is not. So the expected result on an A1200 is a step of **exactly one column** at every band boundary, uniform across all three sections — which is what vAmiga now draws:

```
                ruler edges      data edges     step
lores           69, 85, 101      70, 86, 102     -1
hires           69, 85, 101      70, 86, 102     -1
super hires     69, 85, 101      70, 86, 102     -1
control          61, 77, 93      70, 86, 102     +7
```

On an ECS machine, where there is no such delay, the edges should be perfectly straight. A step of any other size, or a step on ECS, is a finding.

Dirk Hoffmann, 2026
