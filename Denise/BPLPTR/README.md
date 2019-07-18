## Objective

This test suite verfies the timing of the BPLPT registers by changing their values in the middle of a rasterline.

#### bplpt1

Writes to BPL1PTL at increasing Copper location. Note that the value written to BPL1PTL is hard coded (because I didn't know how to do  better). This means that you need to run SAE with a specific hardware configuration to reproduce the reference image. Otherwise, the bitmap data of the referece image might be located at different memory addresses. The following settings have been used:

- Amiga 500 PAL
- Original Chip Set (OCS)
- 512 KB Chip RAM, no Slow RAM, no Fast RAM

#### bplpt2

Same as bplpt1, but BPL2PTL is changed instead of BPL1PTL.

Dirk Hoffmann, 2019