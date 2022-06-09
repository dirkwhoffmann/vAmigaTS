## Objective

Test the number of executed instruction after INTREQ has been written by the CPU. Background: Due to IPL polling delays, the CPU sometimes executes the next instruction before branching to the interrupt routine. 

#### inttim1 - inttim6 

In all tests, INTREQ is written by various variants of the MOVE command. The differ in the following instructions which are either moveq, clr, or add instructions, sometimes with NOPs in between. The color bars indicate how many instructions have been executed before the interrupt hits in.

green:  0 instructions
red:    1 instruction
yellow: 2 instructions

#### enatim1 - enatim4

Utilizes the Copper to modify INTENA and INTREQ in order to trigger interrupts. Interrupt timing is visualized by color bars.

#### timcpu1 - timcpu2

Utilizes the CPU to modify INTENA and INTREQ in order to trigger interrupts. Interrupt timing is visualized by color bars.


Dirk Hoffmann, 2020
