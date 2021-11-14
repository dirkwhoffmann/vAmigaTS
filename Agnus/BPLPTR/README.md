## Objective

Test the bitplane pointer registers.

#### bplptr1

This test enables two bitplanes and draws a vertical bar in each of them. The Copper is utilized to trigger interrupts. In the interrupt handlers, BPL1PTL and BPL2PTL are modified by the CPU. 

#### bplptr2, bplptr2

Similar to bplptr1, but the modification is carried out late in the scanline, around the DMA cycles belonging to the last fetch unit. The writes will interfere with the addition of BPL1MOD and BPL2MOD to BPL1PT and BPL2PT, respectively.

#### dropXY

These tests draw a simple line pattern. The upper half is drawn in lores mode, the lower half is drawn in hires mode. The Copper is utilized to modify a bitplane pointer register in the active DMA area. If the write collides with DMA in a certain way, the write is dropped. The test image reveals when this happens. Notation: X is the number of enabled bitplanes, Y indicates the bitplane whose pointer register is modified. 


Dirk Hoffmann, 2021