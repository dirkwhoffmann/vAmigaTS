## Objective

This test suite verfies particular aspects of the JUMP command (by writing into strobe registers COPJMPx).

#### jump1

At a certain position, Copper list 1 jumps to Copper list 2 which repeats itself. To visualize timing, the background color is alternated continously in the second Copper list.

#### jump2 and jump3, jump3a

Test jump2 triggers a Copper interrupt and executes a WAIT command afterwards. In the interrupt handler, the Copper location register (COP1LC) is written to. The test image reveals that writing to this register doesn't wake up the Copper nor does it affect the Copper's program counter. To let the change take effect, COPJMP1 needs to be written to which is done in jump3.

#### jump4 and jump5

Similar to jump3. The test try to visualize the timing when the Copper is woken up by a write to COPJMP1. For visualization, the background color is changed in the interrupt handler right before COPJMP1 is written to. Furthermore, the background color is changed three times right at the start of the Copper list. Test jump5 changes the background color in the interrupt handler *after* COPJMP1 is written to. It shows that the CPU freezes for a longer time after writing to COPJMP1.


Dirk Hoffmann, 2019