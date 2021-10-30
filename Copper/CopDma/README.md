 ## Objective

Verfies how Copper reacts if DMA is switched on and off under certain circumstances.

#### copdma1

Triggers a Copper interrupt and changes the LC1 register afterwards. In the IRQ handler, Copper DMA is switched off and on to test if the Copper program counter is updabed with the new LC1 value. 

#### copdma2

Triggers a Copper interrupt.  In the IRQ handler, Copper DMA is switched off, the LC1 register is changed, and Copper DMA is reenabled afterwards. In other words: Similar to copdma1, but LC1 is modified by the interrupt handler, not by the Copper.

#### copdma3

Triggers a Copper interrupt and disabled Copper DMA immediately afterwards. In the IRQ handler, Copper DMA is reenabled. 

#### dmatoggle1

The Copper is utilized to trigger an interrupt and to draw yellow and red color stripes afterwards. Inside the interrupt handler, Copper DMA is switched on and off continuously. 

#### cycleE0

This test verifies the handling of DMA cycle E0. This cycle needs special treatment because it can be used by the CPU or the Blitter, but not by the Copper. If the Copper tries to use this cycle, Agnus will deny it. In addition, the cycle will be blocked which means that it cannot be used by the CPU or the Blitter either. 


Dirk Hoffmann, 2019 - 2021
