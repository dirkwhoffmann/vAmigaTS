## Objective

Test timing of BPLxMOD registers.

#### bplmod1

This test enables two bitplanes and draws a vertical bar in each of them. The Copper is utilized to trigger interrupts. In the interrupt handlers, BPL1MOD and BPL2MOD are modified by the CPU. In this particular test, the modifications take place early in the scanline and don't interfere with the actual use of the registers under test (BPL1MOD and BPL2MOD are used in the last fetch unit, only).

#### bplmod2, bplmod3, bplmod4

Similar to bplmod1, but the modification is carried out late in the scanline, around the DMA cycles belonging to the last fetch unit.

#### bplmod5, bplmod6

These tests modify BPL1MOD and BPL2MOD directly by the Copper.


Dirk Hoffmann, 2021
