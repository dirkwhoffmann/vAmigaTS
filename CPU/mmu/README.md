## Objective

Verifies basic properties of the memory management unit.

#### mmureg1, mmureg2

A very basic test for verifying the MMU registers. Some constant values are written into MMUSR, TC, TT0, TT1, CRP, and SRP. The values are read back and displayed on the screen. mmureg1 utilizes the PMOVE command, mmureg2 utilizes PMOVEFD.

#### ptest30r, ptest30w

These tests verifiy the ACU (Access Control Unit) of the 680EC030. Both tests write various values into TT0 (aka AC0). After that, ptest30r issues a PTESTR instruction and ptest30w issues a PTESTW instructions. After each PTEST call, the value of the ACSR (aka MMUSR) is recorded and displayed.

#### pflush30, pflush40

Very simple tests to check if PFLUSH instructions are available. Tests pflush30 and pflush40 execute PFLUSH instructions from the 68030 and 68040 instruction set, respectively. If the instructions are available, green bars appears on the screen. Otherwise, the bars appear in red.

#### pload30

Similar to pflush30, but for the PLOAD instruction.


Dirk Hoffmann, 2022
