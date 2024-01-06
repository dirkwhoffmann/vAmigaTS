## Objective

This test suite checks the interplay between bitplane DMA and sprite DMA. The tests have been set up based on the discussion of GitHub issue #799 in the vAmiga repro. 

#### blocked1 and blocked2

Sprite DMA is blocked temporarily by expanding the DDF window. blocked1 enabled 4 bitplanes, blocked2 enables 2 bitplanes. Test blocked2 fails in vAmiga 2.4 and below. 

#### blocked2

Two bitplanes are enabled like in blocked2. The DDF window is shifted slightly in each block to see if DMA slot allocation is affected.

#### blocked3

A more sophisticated version of blocked2. All 8 sprites are enabled. 


Dirk Hoffmann, 2024
