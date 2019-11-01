## Objective

Verify basic interrupt timing properties (i.e., timing).

#### int1

First half: A level 4 interrupt is issued and acknowledged with varying delays.
Second half: The level 4 interrupt is followed by a level 5 interrupt with varying delay.

#### int2

The CPU runs in an infinite loop. In each iteration, it reads the VERTB bit in INTREQR and changes the background color to green if the bit is set. The Copper changes the color back to red and black. In AmigaForever (most likely on the real machine, too), the upper area toggles between green and black which means that the bit is sometimes 1 and sometimes 0. In the latter case, the IRQ handler has been executed before the CPU was able to check the bit. The result of this test backs the hypthesis that the bit INTREQR changes faster than Paula's IRQ level lines that actually trigger the IRQ inside the CPU.


Dirk Hoffmann, 2019
