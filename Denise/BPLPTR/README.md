## Objective

This test suite verfies the timing of the BPLPT registers by changing BPL0PTL in the middle of a rasterline.

#### bplpt1

Writes to BPLPTL0 at increasing Copper location. Note that the value written to BPL0PTL is hard coded (because I didn't know how to do  better). This means that you need to run SAE with a specific hardware configuration to reproduce the reference image. Otherwise, the bitmap data of the referece image might be located at different memory addresses. The following settings have been used:

- Amiga 500 PAL
- Original Chip Set (OCS)
- 512 KB Chip RAM, no Slow RAM, no Fast RAM

#### bplpt2

Same as bplpt1 with slightly modified Copper trigger coordinates. Please note that the reference image looks very similar to the one created by bplpt1. It's important to watch out for subtle differences.


Dirk Hoffmann, 2019