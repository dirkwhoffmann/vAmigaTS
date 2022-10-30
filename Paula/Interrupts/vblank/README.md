## Objective

Test VBLANK timing. The tests exhibit a difference between Amiga models. Old Agnus revisions (Amiga 1000) trigger the VERTB interrupt in line 1 whereas newer models trigger the interrupt in line 0.

#### vblank1

This test utilizes the CPU to wait until the VBLANK bit in INTREQ is set. Once this happens, color stripes are drawn. The Copper is disabled during VBLANK. 

#### vblank2

Same as vblank1, but with the Copper enabled all the time.

#### vblank3

Similar to vblank1. When the VBLANK bit switches to 1, the CPU reads VHPOSR(HI) and lets the Copper displays the bit pattern.

#### vblank4
 
Same as vblank3 for VHPOSR(LO)

#### vblank5 (vblank6)

Same as vblank3 (vblank4), but VHPOSR is read inside the VBLANK IRQ handler.

#### vblank7 (vblank8)

Same as vblank3 (vblank4) with different polling code.


Dirk Hoffmann, 2019 - 2020
