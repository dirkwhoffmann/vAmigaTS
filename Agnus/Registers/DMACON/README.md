## Objective

Verify timing of the BMPEN line (bitmap enable, see Agnus schematics).

#### bploncop1 - bploncop4

The Copper is utilized to modify the BPLEN bit in DMACON around the trigger cycle. 

#### bploncpu1 - bploncpu4

Same as bploncop1 - bploncop4 with the modification being carried out by the CPU.

#### bploff1

This test exhibits a bug in the Agnus sequencer logic. When bitplane DMA is switched off in the middle of a line (inside the active bpl area), bitplane DMA terminates early once DMA is reenabled. On ECS machines, early termination always happens (only 1 or 2 fetch units are processed). On OCS machines, early termination happens only when DMA is switched off inside or close to the last fetch unit. This bug is not supported by vAmiga, yet. Hence, the test fails. 

#### reenable

In some scanlines, bitplane DMA is disabled after DDFSTRT has been passed and reenabled before DDFSTOP has been reached. 

#### sprdiscop1 - sprdiscop3

Sprite DMA is disabled by the Copper around the sprite fetch cycles.

#### sprenacop1 - sprenacop3

Sprite DMA is enabled by the Copper around the sprite fetch cycles.

#### sprdiscpu1 - sprdiscpu3

Sprite DMA is disabled by the CPU around the sprite fetch cycles.

#### sprenacpu1 - sprenacpu3

Sprite DMA is enabled by the CPU around the sprite fetch cycles.

#### bltspr1 - bltspr2

These tests start the Blitter at the beginning of a line and let it run across the sprite DMA cycles. The Copper is utilized to disable sprite DMA at certain positions.


Dirk Hoffmann, 2022
