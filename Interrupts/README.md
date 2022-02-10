## Objective

#### irqbpl1 - irq1bpl6

These tests run the CPU interrupt initiation code across an area with a varying number of bitplanes enabled. They are intended to verfify exact timing. 

#### irqbpl1b - irq1bpl6b

Same as irqbpl1 - irq1bpl6 with the CPU being out-of-sync. I.e., the cycle in which the interrupt is triggered is shifted by one DMA cycle.


Dirk Hoffmann, 2022