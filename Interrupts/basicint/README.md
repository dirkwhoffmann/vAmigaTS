## Objective

Verify basic interrupt timing properties.

#### int1

First half: A level 4 interrupt is issued and acknowledged with varying delays.
Second half: The level 4 interrupt is followed by a level 5 interrupt with varying delay.

#### int2

Similar to int1 with an additional NOP in the interrupt handler.

#### int3

Issues a level 4 interrupt and acknowledges it with varying delays (similar to int1 first half).

#### int4

Same as int3, but IRQ is acknowledged immediately after triggering.

#### int5

Same as int3, but IRQ is disabled immediately after triggering.

#### int6

Issues a level 4 interrupt followed by a level 5 interrupt (similar to int1 second half).

#### int7

Same idea as int6. It is tried to discard some interrupts by deleting bits in INTREQ. 


Dirk Hoffmann, 2021
