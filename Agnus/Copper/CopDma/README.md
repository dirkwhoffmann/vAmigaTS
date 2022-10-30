 ## Objective

Verfies how Copper reacts if DMA is switched on and off under certain circumstances.

#### dasdma1, dasdma2

Runs the Copper in areas where disk, audio, and sprite DMA is on / off.

#### dmatoggle1

The Copper is utilized to trigger an interrupt and to draw yellow and red color stripes afterwards. Inside the interrupt handler, Copper DMA is switched on and off continuously. 

#### cycleE0

This test verifies the handling of DMA cycle E0. This cycle needs special treatment because it can be used by the CPU or the Blitter, but not by the Copper. If the Copper tries to use this cycle, Agnus will deny it. In addition, the cycle will be blocked which means that it cannot be used by the CPU or the Blitter either. 


Dirk Hoffmann, 2019 - 2021
