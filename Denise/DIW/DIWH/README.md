## Summary
---

### diwtim1 - diwtim4

These test utilize the Copper to modify DIWSTRT and DIWSTOP at locations close to the old trigger coordinate. 


### diwtim1b - diwtim4b

These test utilize the Copper to write trigger coordinates into DIWSTRT and DIWSTOP that are close to the current location. 

### minmax 

This test was mentioned in vAmiga GitHub issue 710. It sets DIWSTRT and DIWSTOP to very small and very high values, respectively. It can be used to determine the smallest and largest meaningful coordinate.

### minmax2

A rectified and slightly enhanced variant of the minmax test.

### minmax3

This test is related to vAmiga GitHub issue #799. Background: The last possible DIW stop is position $1c7, because the DIW counter runs through the sequence $1c6, $1c7, 2, 3, etc.. As a result, values larger than $1c7 will not trigger the DIW logic, thus producing an overscan line. On ECS Denise and Lisa, this can be worked around, because the uppermost stop bit can be modified via DIWHIGH. Therefore, it is possible to use values such as 2, 3, ... as trigger coordinates. This trick is impossible on OCS machines since the uppermost stop bit for the DIW window is hard-coded to 1. This test case exploits the trick and produces a different image if an ECS Denise or Lisa chip is plugged in. 

### diwsub

DIWSTRT and DIWSTOP hold their horizontal coordinate in lores pixels, so the display window can only be placed on even hires pixels and on multiples of four in super hires. AGA adds two two-bit fields to DIWHIGH that supply the missing low bits — bits 4-3 for DIWSTRT, bits 12-11 for DIWSTOP. minmax3 above uses DIWHIGH's two *high* bits; these four low ones had no coverage at all.

The window edges are compared in super hires units and then masked down to the resolution being displayed, so the added bits survive only as far as the current mode can resolve them:

```
lores         all four settings identical, no movement at all
hires         0 and 1 identical, 2 and 3 identical, one hires pixel apart
super hires   four distinct positions, one super hires pixel apart
```

The lores section is the control. The regression reference cannot show the whole of the super hires case, because a screenshot texel covers one hires pixel and an odd super hires step lands on the same column — the section reads as two pairs rather than four positions. All four are visible on a real machine, which is what the A1200 photograph is for.

DIWSTRT sits at lores $90, deliberately **right** of the first bitplane pixel. The display window does not open at DIWSTRT but at the first BPL1DAT write, so a DIWSTRT left of the data would be invisible and the test would measure nothing (see Denise/Sprites/clip/diwclip).

All three recorded references — OCS, ECS and PLUS — show no movement anywhere, which is correct: these are AGA fields. That makes them negative controls, and vAmiga currently implements neither field, so the AGA photograph is where the answer has to come from.

---
Dirk Hoffmann, 2022 - 2026
