## Objective

Test when writes to SPRxPT get dropped.

#### sprdrop1 - sprdrop4

This test draws all 8 sprites. The Copper is utilized to change registers SPRxPTL. Some writes will be dropped (they won't change the register value) because they conflict with sprite DMA.

#### sprdropcpu1 - sprdropcpu6

Similar to sprdrop, but the write to SPRxPTL is carried out by the CPU. 


Dirk Hoffmann, 2021