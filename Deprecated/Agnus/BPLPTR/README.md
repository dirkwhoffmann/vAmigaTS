## Objective

Test the bitplane pointer registers.

#### dropXY

These tests draw a simple line pattern. The upper half is drawn in lores mode, the lower half is drawn in hires mode. The Copper is utilized to modify a bitplane pointer register in the active DMA area. If the write collides with DMA in a certain way, the write is dropped. The test image reveals when this happens. Notation: X is the number of enabled bitplanes, Y indicates the bitplane whose pointer register is modified. 


Dirk Hoffmann, 2021