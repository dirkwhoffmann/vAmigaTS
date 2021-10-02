## Objective

Tests Blitter interrupt timing

#### bltint1

This test has been written to tackle vAmiga bug #466 (High Density by Darkness demo). The demo starts the Blitter and modifies the address of the interrupt handler shortly afterwards. On a real Amiga, the address modification is carried out before the Blitter interrupt occurs (indicated by a green bar). If a red bar appears, the modification has been carried out afterwards.

#### bltint2 - bltint6

Similar to bltint1 with the CLR command replaced by a series of NOPs.

#### bltint7

Similar to bltint1 with the CLR command replaced by RET.


Dirk Hoffmann, 2021