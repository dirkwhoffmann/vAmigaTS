## Objective

Verify 68010 specific properties.

#### colorloop

Simple test to validate loop mode timing. The background color is modified in a DBRA loop with multiple bitplanes enabled.

#### loopXXX

These tests run certain instructions in a DBRA loop with multiple bitplanes enabled. The color stripes reveal timing.

#### VBR1, VBR2

Test VBR1 triggers some interrupts with different values in the vector base register (VBR). VBR2 is similar to VBL1 with garbage values in the lower 10 VBR bits. A red screen is displayed if a 68000 CPU is detected.


Dirk Hoffmann, 2022
